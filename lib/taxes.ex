defmodule Taxes do
  @moduledoc """
  Module to calculate Taxes
  """
  alias Taxes.Calculator
  alias Taxes.DatesCalculator
  alias Taxes.Organizer
  alias Taxes.Types

  @doc """
  Method to calculate Taxes

  We take as a basis that the price passed to the method is include all inclusive taxes.
  Based at this basis, to get Net Price, we should exclude all inclusive taxes from Price.
  To do that, at first step, we should group taxes by type.
  """
  @spec calculate(float() | integer(), [Types.tax()]) :: {:ok, float(), float(), [tuple()]}
  def calculate(
        price,
        taxes,
        exponent \\ 2,
        count_of_persons \\ 1,
        count_of_rooms \\ 1,
        count_of_nights \\ 1
      ) do
    %{
      taxes: taxes,
      raw_price: price,
      count_of_persons: count_of_persons,
      count_of_rooms: count_of_rooms,
      count_of_nights: count_of_nights,
      calculated_taxes: [],
      exponent: exponent
    }
    |> Organizer.convert_taxes_rate()
    |> Organizer.group_taxes()
    |> Calculator.set_net_price()
    |> Calculator.calculate_taxes(:inclusive)
    |> Calculator.calculate_taxes(:exclusive)
    |> Calculator.remove_duplicates()
    |> Calculator.set_total_price()
    |> format_result()
  end

  @spec calculate_with_dates(map(), [Types.tax()]) :: {:ok, float(), float(), [tuple()]}
  def calculate_with_dates(
        dates,
        taxes,
        exponent \\ 2,
        count_of_persons \\ 1,
        count_of_rooms \\ 1
      ) do
    dates
    |> DatesCalculator.calculate(taxes, exponent, count_of_persons, count_of_rooms)
    |> DatesCalculator.aggregate_taxes()
  end

  def format_result(%{net_price: price, total_price: total_price, calculated_taxes: taxes}) do
    {:ok, price, total_price, taxes}
  end
end
