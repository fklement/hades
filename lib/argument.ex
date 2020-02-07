defmodule Hades.Argument do
  @moduledoc false

  @type name :: binary
  @type argument :: binary
  @type options :: boolean
  @type context :: :scan_type | :option | :target
  @type desc :: binary

  @type t :: %__MODULE__{
          name: name,
          argument: argument,
          options: options,
          context: context,
          desc: desc
        }

  defstruct name: nil,
            argument: nil,
            options: false,
            context: :unspecified,
            desc: nil
end
