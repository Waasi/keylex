defmodule TTFAuth.Plugs.GQLSheriff do
  @behaviour Plug

  import Plug.Conn

  def init(_opts), do: []

  def call(conn, _opts) do
    header = get_req_header(conn, "authorization")

    with [token] <- header,
         false <- nil == GenServer.whereis(String.to_atom(token)) do
      [entity | _] = String.split(token, " ")
      put_private(conn, :absinthe, %{context: %{entity: entity}})
    else
      _error -> conn
    end
  end
end
