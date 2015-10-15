defmodule Hemera.Mixfile do
  use Mix.Project

  def project do
    [app: :hemera,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :tzdata, :httpoison, :quantum, :nadia],
    mod: {Hemera, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:timex, "~> 1.0.0-rc1"},
      {:httpoison, "~> 0.7"},
      {:sweet_xml, "~> 0.4.0"},
      {:quantum, "~> 1.4"},
      {:redix, "~> 0.1"},
      {:poolboy, "~> 1.5"},
      {:nadia, "~> 0.3"}
    ]
  end
end
