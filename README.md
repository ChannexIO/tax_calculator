# Channex.io Taxes

Module to calculate taxes based at Raw Price (Net price plus all inclusive taxes and fees)

## Usage

```elixir
taxes = [
  %{
    title: "Service Fee",
    rate: 10.00,
    is_inclusive: false,
    logic: :per_person
  }
]

Taxes.calculate(100.00, taxes, 1)
# output > {:ok, 100.00, 110.00, [{"Service Fee", 10.0}]}
```

Method `calculate/5` accept next arguments:
- raw_price as float
- list of taxes
- count_of_persons (1 by default)
- count_of_rooms (1 by default)
- count_of_nights (1 by default)

Output is tuple with:
- marker of successful operation (:ok | :error)
- net price float value
- full price float value
- list of calculated taxes

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `taxes` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:taxes, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/taxes](https://hexdocs.pm/taxes).

