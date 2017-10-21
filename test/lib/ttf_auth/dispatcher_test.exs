defmodule TTFAuth.DispatcherTest do
  use ExUnit.Case

  alias TTFAuth.Dispatcher

  test "dispatches a passwort process" do
    {:ok, token} = Dispatcher.create_passport("7875555555", "from", "message")
    assert GenServer.whereis(String.to_atom("#{7875555555} #{token}")) != nil
  end
end
