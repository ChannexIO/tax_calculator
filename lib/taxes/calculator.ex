defmodule Taxes.Calculator do
  @moduledoc """
  Module with logic to calculate taxes based at Taxes tree
  """
  alias Taxes.Types
  alias Taxes.Logic

  @hundred_percents 100
  @precision 2

  @doc """
  Method to get Net price from `raw_price` by exclude inclusive taxes
  """
  @spec set_net_price(Types.payload()) :: Types.payload()
  def set_net_price(%{inclusive: taxes, raw_price: price} = payload) do
    %{percent: percent, fixed: fixed} = get_tax_amounts(taxes, %{percent: 0, fixed: 0}, payload)
    price_without_fixed = price - fixed

    percents_amount =
      price_without_fixed -
        price_without_fixed / ((@hundred_percents + percent) / @hundred_percents)

    Map.put(
      payload,
      :net_price,
      Float.round(price_without_fixed - percents_amount, @precision)
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

        case tax.logic do
          :percent ->
            %{
              percent: acc.percent + tax.rate + percent + percent / 100 * (tax.rate / 100) * 100,
              fixed: acc.fixed + fixed + fixed * (tax.rate / 100)
            }

          "percent" ->
            %{
              percent:
                acc.percent + tax.rate + percent + percent / 100 * (tax.rate / 100) * 100,
              fixed: acc.fixed + fixed + fixed * (tax.rate / 100)
            }

          _ ->
            {_, tax_amount} = Logic.calculate_tax(tax, payload)

            %{
              percent: acc.percent + percent,
              fixed: acc.fixed + fixed + tax_amount
            }
        end
      end)
    end)
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

        new_price = Enum.reduce(child_taxes, 0, fn {_, amount}, acc -> acc + amount end) + price
        [Logic.calculate_tax(tax, payload |> Map.put(:price, new_price)) | child_taxes ++ acc]
      end)
    end)
  end

  @doc """
  Method to set total price into payload
  """
  @spec set_total_price(Types.payload()) :: Types.payload
  def set_total_price(%{net_price: net_price, calculated_taxes: taxes} = payload) do
    Map.put(
      payload,
      :total_price,
      net_price + Enum.reduce(taxes, 0, fn {_, amount}, acc -> acc + amount end)
    )
  end
end
