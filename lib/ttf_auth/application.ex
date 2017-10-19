defmodule TTFAuth.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {TTFAuth.Dispatcher, []},
    ]

    opts = [strategy: :one_for_one, name: TTFAuth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
