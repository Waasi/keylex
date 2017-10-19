defmodule TTFAuth.WorkerTest do
  use ExUnit.Case

  setup do
    Application.put_env(:ttf_auth, :sender, TTFAuth.TestHelper.TestMessenger)
    {:ok, pid} = TTFAuth.Worker.start_link("7875555555 ace123", %{from: "from", to: "to", body: "body"})
    {:ok, worker: pid}
  end

  test "expires in 3 seconds", %{worker: worker} do
    assert ^worker = GenServer.whereis(:"7875555555 ace123")
    :timer.sleep(4000)
    assert nil == GenServer.whereis(:ace123)
  end
end
