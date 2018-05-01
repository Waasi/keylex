defmodule Keylex.Plugs.Sheriff do
  @moduledoc """
  Keylex.Plugs.Sheriff will check for an authorization header
  with value: "#\{entity\} #\{code\}" and place the entity in as a
  private property in the Plug.Conn structure.

  Here is an usage example in Phoenix Framework:

  ```elixir
  defmodule MyAppWeb.Router do
    use MyAppWeb, :router

    pipeline :api do
      plug :accepts, ["json"]
      plug Keylex.Plugs.GQLSheriff
    end

    scope "/" do
      pipe_through :api

      # protected routes here
    end
  end
  ```
  """

  import Plug.Conn

  def init(_opts), do: []

  def call(conn, _opts) do
    header = get_req_header(conn, "authorization")

    with [token] <- header,
         false <- nil == GenServer.whereis(String.to_atom(token)) do
      [entity | _] = String.split(token, " ")
      put_private(conn, :entity, entity)
    else
      _error -> conn
    end
  end
end
