defmodule Taxes.Organizer do
  @moduledoc """
  Module with methods to group taxes by markers
  """
  alias Taxes.Types

  @doc """
  Method to wrap taxes from list into tree structure with `:inclusive` and `:exclusive` keys at top level.
  This method modify incoming `payload` structure and add two new keys.
  """
  @spec group_taxes(Types.payload()) :: Types.payload()
  def group_taxes(%{taxes: taxes} = payload) do
    Map.merge(
      payload,
      taxes
      |> build_tree_by_level()
      |> build_taxes_tree()
      |> group_taxes_by(:is_inclusive)
      |> group_taxes_by(:logic)
    )
  end

  def group_taxes(payload), do: payload

  @doc """
  Method to recursive build tax tree based at level option
  """
  def build_tree_by_level(taxes) do
    taxes_by_level = Enum.group_by(taxes, &Map.get(&1, :level, 0))
    taxes =
      taxes
      |> Enum.map(&Map.get(&1, :level, 0))
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.reverse()
      |> Enum.reduce(nil, fn level, acc ->
        taxes_for_level = acc || Map.get(taxes_by_level, level, [])
        higher_level_taxes = Map.get(taxes_by_level, level - 1, [])

        case higher_level_taxes do
          [] -> taxes_for_level
          taxes ->
            taxes |> Enum.map(fn tax -> Map.put(tax, :taxes, tax.taxes ++ taxes_for_level) end)
          end
      end)

    taxes
  end

  @doc """
  Method to recursive build tax tree
  """
  @spec build_taxes_tree([Types.tax()]) :: [Taxes.tax()]
  def build_taxes_tree(taxes) do
    Enum.map(taxes, &wrap_child_taxes_into_tree(&1))
  end

  @doc """
  Method to wrap into tree nested taxes
  """
  @spec wrap_child_taxes_into_tree(Types.tax()) :: Types.tax()
  def wrap_child_taxes_into_tree(%{taxes: taxes} = tax) do
    Map.put(
      tax,
      :taxes,
      taxes
      |> build_taxes_tree()
      |> group_taxes_by(:logic)
    )
  end

  def wrap_child_taxes_into_tree(tax), do: tax

  @doc """
  Method to group taxes by provided marker
  """
  @spec group_taxes_by([Types.tax()] | map(), :atom | String.t()) :: map()
  def group_taxes_by(taxes, mark) when is_map(taxes) do
    Enum.reduce(
      taxes,
      %{},
      fn {group, taxes}, acc -> Map.put(acc, group, group_taxes_by(taxes, mark)) end
    )
  end

  def group_taxes_by(taxes, mark) when is_list(taxes) do
    Enum.group_by(taxes, &get_mark_value(&1, mark))
  end

  @doc """
  Method to fetch marker from Tax.
  """
  @spec get_mark_value(Types.tax(), :atom | String.t()) :: any()
  def get_mark_value(%{is_inclusive: true}, :is_inclusive), do: :inclusive
  def get_mark_value(%{is_inclusive: false}, :is_inclusive), do: :exclusive
  def get_mark_value(tax, field), do: Map.fetch!(tax, field)

  @doc """
  Method to convert taxes rate into float
  """
  @spec convert_taxes_rate(map) :: map
  def convert_taxes_rate(%{taxes: taxes, exponent: exponent} = args) when is_map(args) do
    Map.put(
      args,
      :taxes,
      convert_tax_rate(taxes, exponent)
    )
  end

  def convert_tax_rate(taxes, exponent) when is_list(taxes) do
    Enum.map(taxes, &convert_tax_rate(&1, exponent))
  end

  def convert_tax_rate(%{rate: rate, logic: :percent} = tax, exponent) when is_integer(rate) do
    tax
    |> Map.put(:rate, rate / :math.pow(10, 2))
    |> Map.put(:taxes, convert_tax_rate(Map.get(tax, :taxes, []), exponent))
  end

  def convert_tax_rate(%{rate: rate} = tax, exponent) when is_integer(rate) do
    tax
    |> Map.put(:rate, rate / :math.pow(10, exponent))
    |> Map.put(:taxes, convert_tax_rate(Map.get(tax, :taxes, []), exponent))
  end

  def convert_tax_rate(%{rate: rate} = tax, exponent) when is_binary(rate) do
    tax
    |> Map.put(:rate, String.to_float(rate))
    |> Map.put(:taxes, convert_tax_rate(Map.get(tax, :taxes, []), exponent))
  end

  def convert_tax_rate(tax, _) when is_nil(tax), do: nil

  def convert_tax_rate(tax, _), do: tax
end
