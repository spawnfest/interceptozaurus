defmodule HttpIntercept.MixProject do
  use Mix.Project

  def project do
    [
      app: :http_intercept,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      # :inets and :ssl for :httpc
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  defp deps do
    [
      {:mimic, "~> 1.7"},
      {:jason, "~> 1.4"},
      # Hackney-based GitHub client.
      {:tentacat, "~> 2.0"}
    ]
  end
end
