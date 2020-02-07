defmodule DocTest do
  use ExUnit.Case, async: true
  doctest Hades, except: [scan: 1]
  doctest Hades.Helpers, except: [hades_path: 0]
end
