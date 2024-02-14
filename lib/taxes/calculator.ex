defmodule Taxes.Calculator do
  @moduledoc """
  Module with logic to calculate taxes based at Taxes tree
  """
  alias Taxes.Logic
  alias Taxes.Types

  @hundred_percents 100

  @doc """
  Method to get Net price from `raw_price` by exclude inclusive taxes
  """
  @spec set_net_price(Types.payload()) :: Types.payload()
  def set_net_price(%{inclusive: taxes, raw_price: price, exponent: exponent} = payload) do
    %{percent: percent, fixed: fixed} = get_tax_amounts(taxes, %{percent: 0, fixed: 0}, payload)
    price_without_fixed = price - fixed

    percents_amount =
      price_without_fixed -
        price_without_fixed / ((@hundred_percents + percent) / @hundred_percents)

    Map.put(
      payload,
      :net_price,
      Float.round(price_without_fixed - percents_amount, exponent)
    )
  end

  def set_net_price(%{raw_price: price} = payload) do
    Map.put(payload, :net_price, price)
  end

  @doc """
  Method to calculate taxes based at `payload` and type of taxes
  """
  @spec calculate_taxes(Types.payload(), :atom) :: Types.payload()
  def calculate_taxes(
        %{inclusive: taxes, net_price: price, calculated_taxes: acc} = payload,
        :inclusive
      ) do
    Map.put(payload, :calculated_taxes, calculate_taxes(taxes, price, acc, payload))
  end

  def calculate_taxes(
        %{exclusive: taxes, raw_price: price, calculated_taxes: acc} = payload,
        :exclusive
      ) do
    Map.put(payload, :calculated_taxes, calculate_taxes(taxes, price, acc, payload))
  end

  def calculate_taxes(payload, _), do: payload

  @doc """
  Method to calculate tax amounts
  """
  @spec get_tax_amounts(map(), map(), Types.payload()) :: map()
  def get_tax_amounts(taxes, acc, payload) do
    taxes
    |> Enum.reduce(acc, fn {_mode, taxes}, acc ->
      taxes
      |> Enum.reduce(acc, fn tax, acc ->
        %{percent: percent, fixed: fixed} =
          get_tax_amounts(Map.get(tax, :taxes, %{}), %{percent: 0, fixed: 0}, payload)

        get_tax_amount(tax.logic, acc, tax, fixed, percent, payload)
      end)
    end)
  end

  def get_tax_amount(logic, acc, tax, fixed, percent, _) when logic in [:percent, "percent"] do
    %{
      percent: acc.percent + tax.rate + percent + percent / 100 * (tax.rate / 100) * 100,
      fixed: acc.fixed + fixed + fixed * (tax.rate / 100)
    }
  end

  def get_tax_amount(_, acc, tax, fixed, percent, payload) do
    {_, tax_amount} = Logic.calculate_tax(tax, payload)

    %{
      percent: acc.percent + percent,
      fixed: acc.fixed + fixed + tax_amount
    }
  end

  @doc """
  Method to calculate tax values
  """
  @spec calculate_taxes(map(), float(), list(), Types.payload()) :: list()
  def calculate_taxes(taxes, price, acc, payload) do
    taxes
    |> Enum.reduce(acc, fn {_mode, taxes}, acc ->
      taxes
      |> Enum.reduce(acc, fn tax, acc ->
        child_taxes = calculate_taxes(Map.get(tax, :taxes, %{}), price, [], payload)

        new_price = Enum.reduce(child_taxes, 0, &sum/2) + price
        [Logic.calculate_tax(tax, payload |> Map.put(:price, new_price)) | child_taxes ++ acc]
      end)
    end)
  end

  defp sum({_, amount}, acc), do: acc + amount

  @doc """
  Method to set total price into payload
  """
  @spec set_total_price(Types.payload()) :: Types.payload()
  def set_total_price(%{calculated_taxes: taxes} = payload) do
    net_price = get_net_price(payload)

    payload
    |> Map.put(:net_price, net_price)
    |> Map.put(
      :total_price,
      net_price + Enum.reduce(taxes, 0, fn {_, amount}, acc -> acc + amount end)
    )
  end

  @doc """
  Remove duplicated taxes
  """
  @spec remove_duplicates(Types.payload()) :: Types.payload()
  def remove_duplicates(%{calculated_taxes: taxes} = payload) do
    Map.put(
      payload,
      :calculated_taxes,
      Enum.uniq(taxes)
    )
  end

  defp get_net_price(%{raw_price: raw_price, calculated_taxes: calculated_taxes, taxes: taxes}) do
    inclusive_taxes_amount = get_inclusive_taxes_amount(taxes, calculated_taxes)

    raw_price - inclusive_taxes_amount
  end

  defp get_inclusive_taxes_amount(nil, _calculated_taxes) do
    0
  end

  defp get_inclusive_taxes_amount(taxes, calculated_taxes) do
    Enum.reduce(taxes, 0, fn tax, acc ->
      case tax.is_inclusive do
        true ->
          {_, tax_amount} = find_by_title(calculated_taxes, tax.title)
          acc + tax_amount + get_inclusive_taxes_amount(Map.get(tax, :taxes), calculated_taxes)

        false ->
          acc + get_inclusive_taxes_amount(Map.get(tax, :taxes), calculated_taxes)
      end
    end)
  end

  defp find_by_title(taxes, search) do
    Enum.find(taxes, fn {title, _} -> title == search end)
  end
end
