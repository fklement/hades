defmodule Hades.Arguments do
  @moduledoc """
  Convenience to import all currently available `NMAP` options in `Hades`.

  ### Usage
  Use the following to use all contained `Hades.Arguments`:
  ```
  use Hades.Arguments
  ```


  """

  defmacro __using__(_) do
    quote do
      import Hades.Arguments.ScanTechniques
      import Hades.Arguments.OSDetection
      import Hades.Arguments.ScriptScan
      import Hades.Arguments.ServiceVersionDetection
    end
  end
end
