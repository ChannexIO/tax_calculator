defmodule Taxes.MixProject do
  use Mix.Project

  def project do
    [
      app: :taxes,
      version: "0.3.3",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      name: "Channex Taxes",
      source_url: "https://github.com/ChannexIO/tax_calculator",
      test_coverage: [tool: ExCoveralls],
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def description do
    "Module to calculate taxes for Channex.io project"
  end

  defp deps do
    [
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false},
      {:credo, "~> 1.7.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end

  defp package do
    [
      name: "channex_taxes",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      maintainers: ["Andrew Judis Yudin"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/ChannexIO/tax_calculator"}
    ]
  end
end
