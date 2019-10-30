defmodule Taxes.LogicTest do
  use ExUnit.Case
  alias Taxes.Logic

  test "should calculate percent tax" do
    tax = %{
      title: "TAX",
      rate: 20.00,
      logic: :percent
    }

    payload = %{price: 100.00}

    assert Logic.calculate_tax(tax, payload) == {"TAX", 20.00}
  end

  test "should calculate per_room tax" do
    tax = %{
      title: "TAX",
      rate: 10.00,
      logic: :per_room
    }

    assert Logic.calculate_tax(tax, %{count_of_rooms: 1}) == {"TAX", 10.00}
    assert Logic.calculate_tax(tax, %{count_of_rooms: 2}) == {"TAX", 20.00}
    assert Logic.calculate_tax(tax, %{count_of_rooms: 10}) == {"TAX", 100.00}
  end

  test "should calculate per_room_per_night tax" do
    tax = %{
      title: "TAX",
      rate: 10.00,
      logic: :per_room_per_night
    }

    assert Logic.calculate_tax(tax, %{count_of_rooms: 1, count_of_nights: 1}) == {"TAX", 10.00}
    assert Logic.calculate_tax(tax, %{count_of_rooms: 2, count_of_nights: 1}) == {"TAX", 20.00}
    assert Logic.calculate_tax(tax, %{count_of_rooms: 1, count_of_nights: 2}) == {"TAX", 20.00}
  end

  test "should calculate per_person tax" do
    tax = %{
      title: "TAX",
      rate: 10.00,
      logic: :per_person
    }

    assert Logic.calculate_tax(tax, %{count_of_persons: 1}) == {"TAX", 10.00}
    assert Logic.calculate_tax(tax, %{count_of_persons: 2}) == {"TAX", 20.00}
    assert Logic.calculate_tax(tax, %{count_of_persons: 10}) == {"TAX", 100.00}
  end

  test "should calculate per_person_per_night tax" do
    tax = %{
      title: "TAX",
      rate: 10.00,
      logic: :per_person_per_night
    }

    assert Logic.calculate_tax(tax, %{count_of_persons: 1, count_of_nights: 1}) == {"TAX", 10.00}
    assert Logic.calculate_tax(tax, %{count_of_persons: 2, count_of_nights: 1}) == {"TAX", 20.00}
    assert Logic.calculate_tax(tax, %{count_of_persons: 1, count_of_nights: 2}) == {"TAX", 20.00}
  end

  test "should calculate per_booking tax" do
    tax = %{
      title: "TAX",
      rate: 10.00,
      logic: :per_booking
    }

    assert Logic.calculate_tax(tax, %{}) == {"TAX", 10.00}
  end
end
