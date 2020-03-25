defmodule Hades.Arguments.PortScanSpecification do
    @moduledoc """
    In addition to all of the scan methods discussed previously, Nmap offers options for specifying which ports are scanned and whether the scan order is randomized or sequential. 
    By default, Nmap scans the most common 1,000 ports for each protocol.
    """
    
    alias Hades.Argument
    require Hades.Helpers
  
    @known_options %{
        p: %Argument{
            name: "-p",
            context: :option,
            argument: true,
            desc:
              "Only scan specified ports
              Ex: -p22; -p1-65535; -p U:53,111,137,T:21-25,80,139,8080"
        },
        F: %Argument{
            name: "-F",
            context: :option,
            desc:
              "Fast mode - Scan fewer ports than the default scan"
        },
        r: %Argument{
            name: "-r",
            context: :option,
            desc:
              "Scan ports consecutively - don't randomize"
        },
        top_ports: %Argument{
            name: "--top-ports",
            context: :option,
            argument: true,
            desc:
              "Scan <number> most common ports"
        },
        port_ratio: %Argument{
            name: "--port_ratio",
            context: :option,
            argument: true,
            desc:
              "Scan ports more common than <ratio>"
        }
    }
  
    Hades.Helpers.option_functions(@known_options)
  end
  