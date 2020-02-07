defmodule Hades.Arguments.ScriptScan do
  alias Hades.Argument
  require Hades.Helpers

  @known_options %{
    sC: %Argument{name: "-sC", context: :scan_type, desc: "equivalent to --script=default"},
    script: %Argument{
      name: "--script",
      context: :option,
      argument: true,
      desc:
        "`<Lua scripts>` is a comma separated list of directories, script-files or script-categories"
    },
    script_args: %Argument{
      name: "--script-args",
      context: :option,
      argument: true,
      desc: "[n2=v2,...]>: provide arguments to scripts"
    },
    script_args_file: %Argument{
      name: "--script-args-file",
      context: :option,
      argument: true,
      desc: "provide NSE script args in a file"
    },
    script_trace: %Argument{
      name: "--script-trace",
      context: :option,
      argument: true,
      desc: "Show all data sent and received"
    },
    script_updatedb: %Argument{
      name: "--script-updatedb",
      context: :option,
      desc: "Update the script database"
    },
    script_help: %Argument{
      name: "--script-help",
      context: :option,
      argument: true,
      desc:
        "Show help about scripts. `<Lua scripts>` is a comma-separated list of script-files or script-categories."
    }
  }

  Hades.Helpers.option_functions(@known_options)
end
