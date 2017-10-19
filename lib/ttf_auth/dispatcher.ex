defmodule TTFAuth.Dispatcher do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Supervisor.init([], strategy: :one_for_one, max_restarts: 5)
  end

  def create_passport(entity, from, message) do
    token =
      System.system_time(:millisecond)
      |> Integer.digits()
      |> Enum.take_random(5)
      |> Enum.join()

    Supervisor.start_child(__MODULE__, worker(TTFAuth.Worker, ["#{entity} #{token}", %{from: from, to: entity, body: message}], restart: :transient))
    {:ok, token}
  end
end
