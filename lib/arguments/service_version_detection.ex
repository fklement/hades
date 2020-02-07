defmodule Hades.Arguments.ServiceVersionDetection do
  alias Hades.Argument
  require Hades.Helpers

  @known_options %{
    sV: %Argument{
      name: "-sV",
      context: :scan_type,
      desc: "Probe open ports to determine service/version info"
    },
    version_intensity: %Argument{
      name: "--version-intensity",
      context: :option,
      argument: true,
      desc: "Set from 0 (light) to 9 (try all probes)"
    },
    version_light: %Argument{
      name: "--version-light",
      context: :option,
      desc: "Limit to most likely probes (intensity 2)"
    },
    version_all: %Argument{
      name: "--version-all",
      context: :option,
      desc: "Try every single probe (intensity 9)"
    },
    version_trace: %Argument{
      name: "--version-trace",
      context: :option,
      desc: "Show detailed version scan activity (for debugging)"
    }
  }

  Hades.Helpers.option_functions(@known_options)
end
