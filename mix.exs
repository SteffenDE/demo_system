defmodule ExampleSystem.Mixfile do
  use Mix.Project

  def project do
    [
      app: :example_system,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [release: :prod, "system.upgrade": :prod, "system.node2": :prod],
      aliases: [
        release: ["tailwind default --minify", "phx.digest", "release"]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExampleSystem.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 3.0"},
      {:ecto, "~> 3.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.2"},
      {:plug, "~> 1.7"},
      {:recon, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:swarm, "~> 3.0"},
      {:phoenix_live_view, "~> 0.17.11"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1.9", runtime: Mix.env() == :dev},
      {:stream_data, "~> 0.5.0", only: :test},
      {:assertions, "~> 0.13", only: :test}
    ]
  end
end
