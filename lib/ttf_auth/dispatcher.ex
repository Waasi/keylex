defmodule TTFAuth.Dispatcher do
  use Supervisor
  require Logger

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Supervisor.init([spec()], strategy: :simple_one_for_one, max_restarts: 5)
  end

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
