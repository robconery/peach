defmodule Peach.Mixfile do
  use Mix.Project

  def project do
    [app: :peach,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :tzdata, :moebius],
     mod: {Peach.Store, []}]
  end

  defp deps do
    [
      {:moebius, github: "robconery/moebius", branch: "2.0"},
      {:uuid, "~> 1.1" },
      {:plug, "~> 1.1.1"},
      {:poison, "~> 2.0.1", optional: true}
    ]
  end
end
