defmodule Buffett.Mixfile do
  use Mix.Project

  def project do
    [
    aliases: aliases(),
      app: :buffett,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      description: "Enables messaging between services using Kafka and REST",
      elixir: "~> 1.14",
      package: package(),
      preferred_cli_env: [espec: :test],
      start_permanent: Mix.env == :prod,
      version: "0.3.0"
    ]
  end

  defp aliases do
    [
    ]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Buffett.Application, []},
     applications: [:httpotion, :kafka_ex]]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test]},
      {:ex_doc, ">= 0.29.1", only: :dev},
      {:espec, "~> 1.9", only: :test},
      {:httpotion, "~> 3.2"}, # TODO: Replace with Tesla
      {:kafka_ex, "~> 0.13"},
      {:poison, "~> 5.0.0"},
      {:uuid, "~> 1.1"}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md),
      maintainers: ["Ryan Cammer"],
      licenses: ["MIT"],
      links: %{"github" => "https://github.com/ryancammer/buffett"}
    ]
  end
end
