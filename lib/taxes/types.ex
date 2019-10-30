defmodule Taxes.Types do
  @moduledoc """
  Module with type definition used at Taxes application
  """

  @type tax :: %{
    title: String.t(),
    rate: float(),
    is_inclusive: boolean(),
    logic: :percent,
    taxes: nil | list(tax())
  }

  @type payload :: %{
    :taxes => list(tax()),
    :raw_price => float(),
    :count_of_persons => non_neg_integer(),
    :count_of_rooms => non_neg_integer(),
    :count_of_nights => non_neg_integer(),
    optional(:calculated_taxes) => list(),
    optional(:inclusive) => nil | list(),
    optional(:exclusive) => nil | list(),
    optional(:net_price) => nil | float(),
    optional(:total_price) => nil | float(),
  }
end
