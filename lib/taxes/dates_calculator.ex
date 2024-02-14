defmodule Taxes.DatesCalculator do
  @moduledoc false
  alias Taxes.DateFilter

  def calculate(dates, taxes, exponent, count_of_persons, count_of_rooms) do
    dates
    |> Map.to_list()
    |> Enum.with_index()
    |> Enum.reduce([], fn {{date, price}, index}, acc ->
      taxes = DateFilter.filter(taxes, date, index)
      [Taxes.calculate(price, taxes, exponent, count_of_persons, count_of_rooms, 1) | acc]
    end)
  end

  def aggregate_taxes(results) do
    Enum.reduce(results, {:ok, 0.0, 0.0, []}, fn {:ok, net_price, total_price, calculated_taxes},
                                                 {:ok, net_price_, total_price_,
                                                  calculated_taxes_} ->
      {
        :ok,
        net_price + net_price_,
        total_price + total_price_,
        sum_taxes(calculated_taxes, calculated_taxes_)
      }
    end)
  end

  def sum_taxes(existed_taxes, new_taxes) do
    Enum.reduce(new_taxes, existed_taxes, fn {title, rate}, existed_taxes ->
      case find(existed_taxes, title) do
        nil ->
          existed_taxes ++ [{title, rate}]

        _ ->
          merge_taxes(existed_taxes, {title, rate})
      end
    end)
  end

  defp merge_taxes(taxes, {title, rate}) do
    Enum.map(taxes, fn {title_, rate_} ->
      if title_ == title do
        {title_, rate_ + rate}
      else
        {title_, rate_}
      end
    end)
  end

  defp find(taxes, search) do
    Enum.find(taxes, fn {title, _} -> title == search end)
  end
end
