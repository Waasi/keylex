ExUnit.start()

defmodule TTFAuth.TestHelper.TestMessenger do
  @behaviour TTFAuth.Messenger

  def send_message(from, to, body, code) do
    IO.puts "From: #{from} - To: #{to}| #{body} with code: #{code}"
    :ok
  end
end
