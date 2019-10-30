defmodule Taxes.MixProject do
  use Mix.Project

  def project do
    [
      app: :taxes,
      version: "0.1.2",
      elixir: "~> 1.9",
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
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
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
