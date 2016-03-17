defmodule Peach.Mixfile do
  use Mix.Project

  def project do
    [app: :peach,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :tzdata, :moebius, :maru],
     mod: {Peach.Store, []}
   ]
  end

  defp deps do
    [
      {:moebius, github: "robconery/moebius", branch: "2.0"},
      {:uuid, "~> 1.1" },
      {:plug, "~> 1.1.1"},
      {:poison, "~> 2.0.1", optional: true},
      {:maru, "~> 0.8"},
      {:stripity_stripe, "~> 1.4.0"}
    ]
  end
end
