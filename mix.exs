defmodule ExLedger.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_ledger,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExLedger.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.10"},
      {:polymorphic_embed, "~> 5.0"},
      {:postgrex, ">= 0.0.0", only: [:test]},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.1", only: [:test], runtime: false}
    ]
  end
end
