defmodule Hades.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :hades,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Hades",
      source_url: "https://github.com/fklement/hades",
      docs: documentation(),
      package: package(),
      description: description()
    ]
  end

  # Application configuration.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # List of dependencies.
  defp deps do
    [
      {:sweet_xml, "~> 0.6.6"},
      {:briefly, "~> 0.3"},
      {:elixir_uuid, "~> 1.2"},

      # DEV-DEPS
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  # Package info.
  defp package do
    [
      files: [
        "lib",
        "config",
        "mix.exs",
        ".formatter.exs",
        "README.md",
        "CHANGELOG.md",
        "LICENSE"
      ],
      maintainers: ["Felix Klement"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/fklement/hades"}
    ]
  end

  # Description.
  defp description do
    """
    A wrapper for `NMAP` written in Elixir.
    """
  end

  # Documentation.
  defp documentation do
    [
      main: "Hades",
      source_ref: "v#{@version}",
      logo: "logo.png",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        Arguments: [
          Hades.Arguments.HostDiscovery,
          Hades.Arguments.OSDetection,
          Hades.Arguments.ScanTechniques,
          Hades.Arguments.ScriptScan,
          Hades.Arguments.ServiceVersionDetection
        ],
        Miscs: [
          Hades.Arguments,
          Hades.Helpers,
          Hades.NMAP
        ]
      ]
    ]
  end
end
