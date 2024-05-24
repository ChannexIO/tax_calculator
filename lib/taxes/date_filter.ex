defmodule Taxes.DateFilter do
  @moduledoc """
  Module to filter taxes by date and date_index based arguments such as:
  - applicable_after
  - applicable_before
  - max_nights
  - skip_nights
  """

  @spec filter(taxes :: [Types.tax()], date :: Date.t(), date_index :: integer()) :: [Types.tax()]
  def filter(taxes, date, date_index) do
    Enum.filter(taxes, &apply_filter(&1, date, date_index))
  end

  def apply_filter(tax, date, date_index) do
    filter_by_max_nights(Map.get(tax, :max_nights), date_index) and
      filter_by_skip_nights(Map.get(tax, :skip_nights), date_index) and
      filter_by_date_range(tax, date) and
      filter_per_booking_taxes(Map.get(tax, :logic), date_index)
  end

  def filter_by_max_nights(nil, _), do: true

  def filter_by_max_nights(max_nights, index) do
    max_nights >= index + 1
  end

  def filter_by_skip_nights(nil, _), do: true

  def filter_by_skip_nights(skip_nights, index) do
    skip_nights < index + 1
  end

  def filter_by_date_range(%{applicable_date_ranges: ranges}, date),
    do: filter_by_applicable_range(ranges, date)

  # Remove this method and all nested when applicable_date_ranges will be released
  def filter_by_date_range(tax, date) do
    filter_by_applicable_after(Map.get(tax, :applicable_after), date) and
      filter_by_applicable_before(Map.get(tax, :applicable_before), date)
  end

  def filter_by_applicable_range(nil, _), do: true
  def filter_by_applicable_range([], _), do: true

  def filter_by_applicable_range(ranges, date) do
    Enum.any?(ranges, &included_into_range?(&1, date))
  end

  defp included_into_range?(%{after: nil, before: before_date}, date) do
    Date.compare(date, before_date) in [:eq, :lt]
  end

  defp included_into_range?(%{after: after_date, before: nil}, date) do
    Date.compare(date, after_date) in [:eq, :gt]
  end

  defp included_into_range?(%{after: after_date, before: before_date}, date) do
    Date.compare(date, after_date) in [:eq, :gt] and Date.compare(date, before_date) in [:eq, :lt]
  end

  def filter_by_applicable_after(nil, _), do: true

  def filter_by_applicable_after(applicable_after, date) do
    Date.compare(date, applicable_after) in [:eq, :gt]
  end

  def filter_by_applicable_before(nil, _), do: true

  def filter_by_applicable_before(applicable_before, date) do
    Date.compare(date, applicable_before) in [:eq, :lt]
  end

  def filter_per_booking_taxes("per_booking", 0), do: true
  def filter_per_booking_taxes(:per_booking, 0), do: true
  def filter_per_booking_taxes("per_room", 0), do: true
  def filter_per_booking_taxes(:per_room, 0), do: true
  def filter_per_booking_taxes("per_person", 0), do: true
  def filter_per_booking_taxes(:per_person, 0), do: true
  def filter_per_booking_taxes("per_booking", _), do: false
  def filter_per_booking_taxes(:per_booking, _), do: false
  def filter_per_booking_taxes("per_room", _), do: false
  def filter_per_booking_taxes(:per_room, _), do: false
  def filter_per_booking_taxes("per_person", _), do: false
  def filter_per_booking_taxes(:per_person, _), do: false
  def filter_per_booking_taxes(_, _), do: true
end
