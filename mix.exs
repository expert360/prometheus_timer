defmodule PrometheusTimer.MixProject do
  use Mix.Project

  def project do
    [
      app: :prometheus_timer,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      elixirc_paths: elixirc_paths(Mix.env),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      mod: {PrometheusTimer.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:prometheus_ex, "~> 3.0"},
      {:httpoison, ">= 0.0.0", only: [:dev, :test]},
      {:plug, ">= 0.0.0", only: [:dev, :test]},
      {:cowboy, "~> 1.0", only: [:dev, :test]},
      {:prometheus_plugs, ">= 0.0.0", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:excoveralls, ">= 0.0.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE.md),
      links: %{"GitHub" => "https://github.com/expert360/prometheus_timer"},
      licenses: ["Apache 2.0"],
      maintainers: ["Declan Kennedy"],
    ]
  end

  defp description do
    "A helper for adding Prometheus timers to functions using annotations"
  end

  def elixirc_paths(:test), do: elixirc_paths(:dev) ++ ["test/support"]
  def elixirc_paths(_), do: ["lib"]
end
