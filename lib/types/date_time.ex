defmodule Bliss.DateTime do
  alias Bliss.{Result, Error, Any}

  use Bliss.Type,
    options: Bliss.Any.__bliss__(:options) ++ [:parse, :allow_int, :shift, :trunc, :min, :max]

  def check(result, rules, context) do
    result
    |> Any.check(rules, context)
    |> maybe_check(:parse, rules, context)
    |> maybe_check(:allow_int, rules, context)
    |> check(:type, rules, context)
    |> maybe_check(:shift, rules, context)
    |> maybe_check(:trunc, rules, context)
    |> maybe_check(:min, rules, context)
    |> maybe_check(:max, rules, context)
  end

  def check(result, _rule, _options, _context) when result.value == nil do
    result
  end

  def check(result, :parse, _format, _context) when not is_binary(result.value) do
    result
  end

  def check(result, :parse, false, _context) do
    result
  end

  def check(result, :parse, true, context) do
    check(result, :parse, :iso8601, context)
  end

  def check(result, :parse, format, context) when format not in [:iso8601] do
    message = "unable to parse DateTime with format: #{inspect(format)}, format must be :iso8601"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :parse, _format, context) do
    case DateTime.from_iso8601(result.value) do
      {:ok, datetime, _offset} ->
        result |> Result.set_value(datetime)

      {:error, _} ->
        message = "unable to parse input as a DateTime"

        result
        |> Result.add_error(
          Error.new(
            Error.Codes.invalid_string(),
            message,
            context
          )
        )
    end
  end

  def check(result, :allow_int, _mode, _context) when not is_integer(result.value) do
    result
  end

  def check(result, :allow_int, false, _context) do
    result
  end

  def check(result, :allow_int, true, context) do
    check(result, :parse, :unix, context)
  end

  def check(result, :allow_int, mode, context) when mode not in [:unix, :gregorian] do
    message =
      "unable to convert to DateTime with mode: #{inspect(mode)}, mode must be :unix or :gregorian"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :allow_int, mode, context) do
    case mode do
      :unix ->
        from_unix(result, context)

      :gregorian ->
        from_gregorian(result, context)
    end
  end

  def check(result, :type, options, context) when not is_struct(result.value, DateTime) do
    message = Keyword.get(options, :message, "input is not a DateTime")

    result
    |> Bliss.Result.add_error(
      Bliss.Error.new(
        Bliss.Error.Codes.invalid_type(),
        message,
        context
      )
    )
  end

  def check(result, :type, _options, _context) do
    result
  end

  def check(result, _rule, _options, _context) when not is_struct(result.value, DateTime) do
    result
  end

  defp from_unix(result, context) do
    case DateTime.from_unix(result.value) do
      {:ok, datetime} ->
        result |> Result.set_value(datetime)

      {:error, _} ->
        message = "unable to convert unix input to a DateTime"

        result
        |> Result.add_error(
          Error.new(
            Error.Codes.invalid_string(),
            message,
            context
          )
        )
    end
  end

  defp from_gregorian(result, _context) do
    datetime = DateTime.from_gregorian_seconds(result.value)

    result |> Result.set_value(datetime)
  end
end
