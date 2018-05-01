ExUnit.start()

defmodule Keylex.TestHelper.TestMessenger do
  @behaviour Keylex.Messenger

  def send_message(from, to, body, code) do
    IO.puts "From: #{from} - To: #{to}| #{body} with code: #{code}"
    :ok
  end
end
