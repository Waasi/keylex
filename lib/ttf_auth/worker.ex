defmodule TTFAuth.Worker do
  @moduledoc false

  use GenServer
  require Logger

  #####
  # Public API
  #####

  def start_link(token, payload) do
    Logger.info("Starting worker")
    GenServer.start_link(__MODULE__, [token, payload], name: String.to_atom(token))
  end

  #####
  # GenServer Callbacks
  #####

  def init([token, %{from: from, to: to, body: body} = payload]) do
    reference =
      sender()
      |> Process.spawn(:send_message, [from, to, body, code_from(token)], [])
      |> Process.monitor()

    Logger.info("Messenger Process Started with reference: #{inspect(reference)} | Restart count: 0")
    {:ok, %{token: token, payload: payload, restart_count: 0}}
  end

  def handle_info({:DOWN, _, :process, _, :normal}, %{token: token} = state) do
    :timer.apply_after(expiration_time(), GenServer, :stop, [String.to_atom(token), :normal])
    Logger.info("Messenger Process Successfully sent message.")
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, _, _}, %{restart_count: 5, token: token} = state) do
    Logger.debug("Messenger Process Failed to Run. Stoping Worker...")
    GenServer.stop(String.to_atom(token), :kill)
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, _, _}, %{restart_count: count, token: token, payload: %{from: from, to: to, body: body}} = state) do
    reference =
      sender()
      |> Process.spawn(:send_message, [from, to, body, code_from(token)], [])
      |> Process.monitor()

    Logger.info("Messenger Process Started with reference: #{inspect(reference)} | Restart count: #{count + 1}")
    {:noreply, %{state | restart_count: count + 1}}
  end

  def terminate(:normal, state) do
    Logger.info("Expiring authentication token with state #{inspect(state)}")
  end

  def terminate(_, state) do
    Logger.debug("Terminating damaged worker with state #{inspect(state)}")
  end

  #####
  # Private API
  #####

  defp expiration_time do
    Application.get_env(:ttf_auth, :expiration_time)
  end

  defp sender do
    Application.get_env(:ttf_auth, :sender)
  end

  defp code_from(token) do
    token
    |> String.split(" ")
    |> Enum.at(1)
  end
end
