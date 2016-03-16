defmodule Redfour.Web.Mixfile do
  use Mix.Project

  def project do
    [app: :web,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Redfour.Web, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :peach, :stripity_stripe]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
    {:phoenix, "~> 1.0.3"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:number, "~> 0.4.1"},
     {:earmark, "> 0.1.0"},
     {:peach, in_umbrella: true},
     { :uuid, "~> 1.1" },
     {:stripity_stripe, "~> 1.4.0"},
     {:poison, "~> 2.0.1", override: true}
   ]
  end
end
