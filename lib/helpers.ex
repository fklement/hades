defmodule Hades.Helpers do
  @moduledoc """
  Provides some usefull functions for internal handling `NMAP` outputs.
  """
  import SweetXml
  require Logger
  alias Hades.Command
  alias Hades.Argument

  @doc """
  This functions parses the given file that is located at `filepath` and
  returns a `t:map/0` filled with the `hosts` and `time` content that was saved
  from `NMAP` into the `XML` file.

  Returns `t:map/0`.

  ## Example
      iex> Hades.Helpers.parse_xml("test/mocs/test.xml")
      %{
        hosts: [
          %{hostname: "FelixsMACNCHEESEPRO.root.box", ip: "192.168.120.42", ports: []}
        ],
        time: %{
          elapsed: 0.03,
          endstr: "Fri Feb  7 09:55:09 2020",
          startstr: "Fri Feb  7 09:55:09 2020",
          unix: 1581065709
        }
      }
  """
  @spec parse_xml(String.t()) :: map
  def parse_xml(filepath) do
    File.read!(filepath)
    |> xmap(
      hosts: [
        ~x"//host"l,
        ip: ~x"./address/@addr"s,
        hostname: ~x"./hostnames/hostname/@name[1]"s,
        ports: [
          ~x"//port"l,
          port: ~x"./@portid"i,
          product: ~x"./service/@product"s,
          name: ~x"./service/@name"s,
          version: ~x"./service/@version"s,
          script: ~x"./script/@id"sl,
          output: ~x"./script/@output"l,
          state: ~x"./state/@state"s
        ]
      ],
      time: [
        ~x"//nmaprun",
        startstr: ~x"./@startstr"s,
        endstr: ~x"./runstats/finished/@timestr"s,
        elapsed: ~x"./runstats/finished/@elapsed"f,
        unix: ~x"./runstats/finished/@time"i
      ]
    )
  end

  @doc """
  With this function it is possible to validate given IP Adresses.

  Returns `{:ok, ip_address}` if the given `ip_address` was validated successfully.

  ## Example
      iex> Hades.Helpers.check_ip_address("192.168.120.1")
      {:ok, "192.168.120.1"}

  """
  # TODO: Also provide a technique to test for submask and FQDN's
  @spec check_ip_address(String.t()) :: {atom, String.t()}
  def check_ip_address(ip_address) do
    case :inet.parse_address(String.to_charlist(ip_address)) do
      {:ok, _ip} ->
        {:ok, ip_address}

      {:error, :einval} ->
        {:error, "No valid IP-Address given."}
    end
  end

  @doc """
  Macro used to generate the argument functions that are described inside
  the `Hades.Arguments` modules.
  """
  defmacro option_functions(options_map) do
    quote bind_quoted: [options_map: options_map] do
      Enum.each(options_map, fn {k, v} ->
        function_name = String.to_atom("arg_" <> Atom.to_string(k))

        if v.argument do
          @doc """
          #{v.desc}
          """
          def unquote(function_name)(argument),
            do: Map.put(unquote(Macro.escape(v)), :argument, argument)
        else
          @doc """
          #{v.desc}
          """
          def unquote(function_name)(), do: unquote(Macro.escape(v))
        end
      end)
    end
  end

  @doc """
  If the context is not directly specified simply return `:ok`.

  Returns `:ok`.

  ## Example
      iex> Hades.Helpers.validate_contexts!(:unspecified, [:scan_type, :option])
      :ok

  """
  def validate_contexts!(:unspecified, _), do: :ok

  @doc """
  Checks if the given context is in the required ones.

  Raises `raise(ArgumentError)` if the given context is not in the required ones.

  ## Examples
      iex> Hades.Helpers.validate_contexts!(:option, [:scan_type, :option])
      nil

      iex> Hades.Helpers.validate_contexts!(:undefined, [:scan_type, :option])
      ** (ArgumentError) argument error

  """
  def validate_contexts!(context, required) do
    unless Enum.member?(required, context), do: raise(ArgumentError)
  end

  @doc """
  Prepares the command to be executed, by converting the `%Command{}` into
  proper parameters to be fed to NMAP.

  Under normal circumstances `Hades.scan/1` should be used, use `prepare`
  only when converted args are needed.

  Returns `{nmap_args_string, the_aimed_target}`.

  ## Example
      iex> command = Hades.new_command()
      ...> |> Hades.add_argument(Hades.Arguments.ServiceVersionDetection.arg_sV())
      ...> |> Hades.add_argument(Hades.Arguments.ServiceVersionDetection.arg_version_all())
      ...> |> Hades.add_argument(Hades.Arguments.ScriptScan.arg_script("vulners"))
      ...> |> Hades.add_target("192.168.0.1")
      iex> Hades.Helpers.prepare(command)
      {"--script vulners --version-all -sV", "192.168.0.1"}

  """
  @spec prepare(command :: Command.t()) :: {binary() | nil, list(binary)}
  def prepare(%Command{scan_types: scan_types, target: target}) do
    if (length(scan_types) == 0) do
      raise ArgumentError, "Must specify atleast one scan type"
    end

    if (target == "") do
      raise ArgumentError, "Must specify a target"
    end
    options = Enum.map(scan_types, &arg_for_option/1) |> List.flatten()
    {Enum.join(options, " "), target}
  end

  defp arg_for_option(%Argument{name: name, options: false, argument: nil}) do
    ~w(#{name} )
  end

  defp arg_for_option(%Argument{name: name, argument: arg}) when not is_nil(arg) do
    ~w(#{name} #{arg} )
  end

  @doc """
  Read hades `timeout` from the config.
  If unspecified, return the default `timeout` which is currently `300_000` (corresponds to 5 minutes).
  This `timeout` is propagated to the function `Task.await()`.
  If the specified `timeout` period is exceeded, it is assumed that the process running the NMAP command has timed out.
  The `timeout` is specified in `ms`.

  Returns `t:integer/0`.

  ## Example
      iex> Hades.Helpers.hades_timeout()
      300000
  """
  def hades_timeout do
    case Application.get_env(:hades, :timeout, nil) do
      nil -> 300_000
      timeout -> timeout
    end
  end

  @doc """
  Reads hades `output_path` from the config.
  If there is nothing specified in the config then the default path will be returned.

  Returns `t:binary/0`.

  ## Example
      iex> Hades.Helpers.hades_path()
      "/var/folders/c1/f0tm33sd3tgg_ds8kyhykyw80000gn/T/briefly-1581/hades-73279-791202-3hades/8b09d31e1a1142869ce8b15faf27ed45.xml"
  """
  def hades_path do
    case Application.get_env(:hades, :output_path, nil) do
      nil ->
        {:ok, path} = Briefly.create(directory: true)
        path <> "/" <> UUID.uuid4(:hex) <> ".xml"

      path ->
        path
    end
  end
end
