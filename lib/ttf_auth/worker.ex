defmodule TTFAuth.Worker do
  use GenServer

  #####
  # Public API
  #####

  def start_link(token, payload) do
    GenServer.start_link(__MODULE__, [token, payload], name: String.to_atom(token))
  end

  #####
  # GenServer Callbacks
  #####

  def init([token, %{from: from, to: to, body: body} = payload]) do
    sender()
    |> Process.spawn(:send_message, [from, to, body, code_from(token)], [])
    |> Process.monitor()

    {:ok, %{token: token, payload: payload, restart_count: 0}}
  end

  def handle_info({:DOWN, _, :process, _, :normal}, %{token: token} = state) do
    :timer.apply_after(expiration_time(), GenServer, :stop, [String.to_atom(token)])
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, _, :normal}, %{restart_count: 5, token: token} = state) do
    GenServer.stop(String.to_atom(token), :kill)
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, _, _}, %{restart_count: count, token: token, payload: %{from: from, to: to, body: body}} = state) do
    sender()
    |> Process.spawn(:send_message, [from, to, body, code_from(token)], [])
    |> Process.monitor()

    {:noreply, %{state | restart_count: count + 1}}
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
