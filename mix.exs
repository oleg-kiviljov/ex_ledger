defmodule ExLedger.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_ledger,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExLedger.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.10"},
      {:polymorphic_embed, "~> 5.0"},
      {:postgrex, ">= 0.0.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
