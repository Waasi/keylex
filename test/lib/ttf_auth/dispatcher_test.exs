defmodule TTFAuth.DispatcherTest do
  use ExUnit.Case

  alias TTFAuth.Dispatcher

  test "dispatches a passwort process" do
    {:ok, pid} = Dispatcher.create_passport("7875555555", "from", "message")
    assert ^pid = GenServer.whereis(pid)
  end
end
