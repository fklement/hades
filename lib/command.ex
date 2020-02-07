defmodule Hades.Command do
  @moduledoc false

  alias Hades.ScanType

  @type target :: binary
  @type scan_types :: [ScanType.t()]

  @type t :: %__MODULE__{
          scan_types: scan_types,
          target: target
        }

  defstruct target: "",
            scan_types: []
end
