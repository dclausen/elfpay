defmodule ElfPay.MixProject do
  use Mix.Project

  def project do
    [
      app: :elf_pay,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [
        "ecto.setup": ["ecto.create", "ecto.migrate"],
        "ecto.reset": ["ecto.drop", "ecto.setup"]
      ],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElfPay.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:ecto_sqlite3, "~> 0.7.3"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:patch, "~> 0.12.0", only: [:test]},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
