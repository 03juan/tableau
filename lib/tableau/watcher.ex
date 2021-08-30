defmodule Tableau.Watcher do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_args) do
    FileSystem.subscribe(:tableau_file_watcher)

    {:ok, %{}}
  end

  def handle_info({:file_event, _watcher_pid, {_path, _event}}, state) do
    Registry.dispatch(Tableau.LiveReloadRegistry, :reload, fn entries ->
      for {pid, _} <- entries, do: send(pid, :reload)
    end)

    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.warn("Unhandled message: #{inspect(message)}")

    {:noreply, state}
  end
end
