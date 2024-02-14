defmodule Taxes.Logic do
  @moduledoc """
  Module with logic operations to calculate each type of tax
  """
  alias Taxes.Types

  @spec calculate_tax(Types.tax(), Types.payload()) :: {String.t(), float()}
  def calculate_tax(%{title: title, rate: rate, logic: :percent}, %{
        price: price,
        exponent: exponent
      }) do
    {title, Float.round(price * (rate / 100), exponent)}
  end

  def calculate_tax(%{title: title, rate: rate, logic: :per_room}, %{
        count_of_rooms: count_of_rooms
      }) do
    {title, rate * count_of_rooms}
  end

  def calculate_tax(%{title: title, rate: rate, logic: :per_night}, %{
        count_of_nights: count_of_nights
      }) do
    {title, rate * count_of_nights}
  end

  def calculate_tax(%{title: title, rate: rate, logic: :per_room_per_night}, %{
        count_of_rooms: count_of_rooms,
        count_of_nights: count_of_nights
      }) do
    {title, rate * count_of_rooms * count_of_nights}
  end

  def calculate_tax(%{title: title, rate: rate, logic: :per_person}, %{
        count_of_persons: count_of_persons
      }) do
    {title, rate * count_of_persons}
  end

  def calculate_tax(%{title: title, rate: rate, logic: :per_person_per_night}, %{
        count_of_nights: count_of_nights,
        count_of_persons: count_of_persons
      }) do
    {title, rate * count_of_persons * count_of_nights}
  end

  def calculate_tax(%{title: title, rate: rate, logic: :per_booking}, _) do
    {title, rate}
  end

  def calculate_tax(%{logic: logic} = tax, payload) when is_binary(logic) do
    tax
    |> Map.put(:logic, String.to_existing_atom(logic))
    |> calculate_tax(payload)
  end
end
