defmodule TTFAuth.Dispatcher do
  @moduledoc """
  TTFAuth.Dispatcher implements the Supervisor behaviour.
  Dispatches messeges with generated access codes.
  """

  use Supervisor
  require Logger

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  create_passport/3 creates an access code and dispatches a worker
  process representing the access code and a messenger process to
  send the code.

  Returns: `{:ok, access_code} | {:error, error_message}`

  ## Example

    ```elixir
    TTFAuth.Dispatcher("5555555555", "4444444444", "Message")
    {:ok, "thisistheaccesscode"}
    ```
  """

  @spec create_passport(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def create_passport(entity, from, message) do
    token =
      System.system_time(:millisecond)
      |> Integer.digits()
      |> Enum.take_random(5)
      |> Enum.join()

    response = Supervisor.start_child(__MODULE__, ["#{entity} #{token}", %{from: from, to: entity, body: message}])
    log_dispacth(response)

    case response do
      {:error, _} ->
        {:error, "an authentication code exist for #{entity}"}
      {:ok, _} ->
        {:ok, token}
    end
  end

  #####
  # Callbacks
  #####

  def init([]) do
    Supervisor.init([spec()], strategy: :simple_one_for_one, max_restarts: 5)
  end

  #####
  # Private
  #####

  defp log_dispacth(response) do
    response
    |> inspect()
    |> Logger.debug()
  end

  defp spec do
    %{
      id: TTFAuth.Worker,
      start: {TTFAuth.Worker, :start_link, []},
      restart: :transient,
      type: :worker
    }
  end
end
