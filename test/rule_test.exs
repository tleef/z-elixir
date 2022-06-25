defmodule Bliss.Rule.Test do
  use ExUnit.Case, async: true

  alias Bliss.Rule

  describe "Bliss.Rule.has_rule/2" do
    test "given a list of rules, when rule in list, returns true" do
      rules = [:required, default: "value", max: {8, message: "hello"}]

      assert Rule.has_rule?(rules, :required)
      assert Rule.has_rule?(rules, :default)
      assert Rule.has_rule?(rules, :max)
    end

    test "given a list of rules, when rule not in list, returns false" do
      rules = [:required, default: "value", max: {8, message: "hello"}]

      assert not Rule.has_rule?(rules, :other)
    end
  end

  describe "Bliss.Rule.delete/2" do
    test "given a list of rules, when rule in list, deletes rule from list" do
      rules = [:required, default: "value", max: {8, message: "hello"}]

      assert Rule.delete(rules, :required) == [default: "value", max: {8, message: "hello"}]
      assert Rule.delete(rules, :default) == [:required, max: {8, message: "hello"}]
      assert Rule.delete(rules, :max) == [:required, default: "value"]
    end

    test "given a list of rules, when rule not in list, returns list" do
      rules = [:required, default: "value", max: {8, message: "hello"}]

      assert Rule.delete(rules, :other) == rules
    end
  end

  describe "Bliss.Rule.rule_name/1" do
    test "given a rule, when rule a keyword, returns rule name" do
      assert Rule.rule_name({:default, 12}) == :default
      assert Rule.rule_name({:max, {8, [message: "whatever"]}}) == :max
    end

    test "given a rule, when rule an atom, returns rule name" do
      assert Rule.rule_name(:required) == :required
    end
  end
end
