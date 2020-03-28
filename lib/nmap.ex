defmodule Hades.NMAP do
  @moduledoc """
  Executes and monitors the desired `NMAP` command with the help of `GenServer`.

  Terminated or aborted are getting cleaned up with `:trap_exit`.
  """
  use GenServer
  require Logger
  alias Hades.Helpers

  @timeout Helpers.hades_timeout()

  def execute(args, opts \\ []) do
    case args do
      {_option, _target} ->
        file_path =
          GenServer.start_link(__MODULE__, [args] ++ [self()], opts)
          |> Hades.NMAP.await()

        case file_path do
          {:ok, file_path} ->
            Helpers.parse_xml(file_path)

          {_error, error_msg} ->
            {:error, error_msg}
        end

      _ ->
        {:error, "Wrong arguments given."}
    end
  end

  def await(_genserver_return, timeout \\ @timeout) do
    receive do
      {:finished, file_path} -> {:ok, file_path}
    after
      timeout -> {:detection_timeout, "Process runned into timeout"}
    end
  end

  def init([{option, target}, self_pid]) do
    Process.flag(:trap_exit, true)

    path = Helpers.hades_path()
  
    target_vector = String.splitter("#{target}", ["/"]) |> Enum.take(2)
    command = if (length(target_vector) == 2) do 
      subnet = Enum.at(target_vector, 1)
      "nmap #{option} -oX #{path} #{target} / #{subnet}"
    else
      "nmap #{option} -oX #{path} #{target}"
    end

    port =
      Port.open({:spawn, command}, [
        :binary,
        :exit_status
      ])

    Port.monitor(port)

    {:ok,
     %{
       port: port,
       file_path: path,
       self_pid: self_pid,
       latest_output: nil,
       exit_status: nil
     }}
  end

  def terminate(reason, %{port: port} = state) do
    Logger.info("** TERMINATE: #{inspect(reason)}.")
    Logger.info("Final state: #{inspect(state)}")

    port_info = Port.info(port)
    os_pid = port_info[:os_pid]

    Logger.warn("Orphaned OS process: #{os_pid}")

    :normal
  end

  def handle_info({port, {:data, text_line}}, %{port: port} = state) do
    Logger.info("NMAP Output: #{inspect(text_line)}")
    {:noreply, %{state | latest_output: String.trim(text_line)}}
  end

  def handle_info({port, {:exit_status, status}}, %{port: port, file_path: file_path} = state) do
    Logger.info("Port exit: :exit_status: #{status}")

    new_state = %{state | exit_status: status}

    send(state.self_pid, {:finished, file_path})

    {:noreply, new_state}
  end

  def handle_info({:DOWN, _ref, :port, port, :normal}, state) do
    Logger.info("DOWN message from port: #{inspect(port)}")
    {:noreply, state}
  end

  def handle_info({:EXIT, _port, :normal}, state) do
    Logger.info("EXIT")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("Unhandled message: #{inspect(msg)}")
    {:noreply, state}
  end
end
