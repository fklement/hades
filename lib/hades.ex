defmodule Hades do
  @moduledoc """
  A wrapper for `NMAP` written in Elixir.

  Nmap (network mapper), the god of port scanners used for network discovery and the basis for most security enumeration during the initial stages of a penetration test. The tool was written and maintained by Fyodor AKA Gordon Lyon.

  Nmap displays exposed services on a target machine along with other useful information such as the verion and OS detection.

  Nmap has made twelve movie appearances, including The Matrix Reloaded, Die Hard 4, Girl With the Dragon Tattoo, and The Bourne Ultimatum.

  ### Nmap in a nutshell

  - Host discovery
  - Port discovery / enumeration
  - Service discovery
  - Operating system version detection
  - Hardware (MAC) address detection
  - Service version detection
  - Vulnerability / exploit detection, using Nmap scripts (NSE
  """

  alias Hades.Command
  alias Hades.Argument
  alias Hades.Helpers

  use Hades.Arguments

  @doc """
  Begin a new blank (no options) `NMAP` command.

  Returns `%Hades.Command{}`.

  ## Example
      iex> Hades.new_command()
      %Hades.Command{scan_types: [], target: ""}
  """
  def new_command, do: %Command{}

  @doc """
  With the scan function you can start the execute of a existing nmap command to your desired target.

  Returns the parsed `NMAP` output in a `t:map/0`.

  ## Example
      iex> Hades.new_command()
      ...> |> Hades.add_argument(Hades.Arguments.ScanTechniques.arg_sP())
      ...> |> Hades.add_target("192.168.120.42")
      ...> |> Hades.scan()
      %{
        hosts: [
          %{hostname: "Felixs-MACNCHEESEPRO.root.box", ip: "192.168.120.42", ports: []}
        ],
        time: %{
          elapsed: 0.93,
          endstr: "Sat Jan 18 10:07:32 2020",
          startstr: "Sat Jan 18 10:07:31 2020",
          unix: 1579338452
        }
      }
  """
  def scan(command) do
    {command, target} = Helpers.prepare(command)

    Hades.NMAP.execute({command, target})
  end

  @doc """
  This function adds the ability to add a specific `target_ip` to the nmap `command`.
  Currently there are only standard formatted IPv4 adresses supported.
  Inputs with trailing subnmasks are not supported, but I'll work on this in the future.

  Returns a `%Hades.Command{}` with the added `target_ip`.

  ## Example
      iex> Hades.new_command()
      ...> |> Hades.add_target("192.168.120.42")
      %Hades.Command{scan_types: [], target: "192.168.120.42"}
  """
  def add_target(%Command{} = command, target_ip) do
    target_ip =
      case Helpers.check_ip_address(target_ip) do
        {:ok, ip} -> ip
        _ -> nil
      end

    %Command{command | target: target_ip}
  end

  @doc """
  The `add_argument` function adds the ability to bind the in `Hades.Arguments`
  defined aruments to the given command.

  Returns a `%Hades.Command{}` with the added `%Hades.Argument{}`.

  ## Example
      iex> Hades.new_command()
      ...> |> Hades.add_argument(Hades.Arguments.ScanTechniques.arg_sP())
      %Hades.Command{
        scan_types: [
          %Hades.Argument{
            argument: nil,
            context: :scan_type,
            desc: "Ping Scan",
            name: "-sP",
            options: false
          }
        ],
        target: ""
      }
  """
  def add_argument(
        %Command{scan_types: scan_types} = command,
        %Argument{context: context} = scan_type
      ) do
    Helpers.validate_contexts!(context, [:scan_type, :option])
    %Command{command | scan_types: [scan_type | scan_types]}
  end

end
