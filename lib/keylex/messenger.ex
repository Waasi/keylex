defmodule Keylex.Messenger do
  @moduledoc """
  Keylex.Messenger provides a behaviour for future and custom Messenger Implementations for example:

  ```elixir
  defmodule MyApp.Messenger do
    @behaviour Keylex.Messenger

    def send_message(from, to, body, code) do
      message = "use this code #\{code\} to #\{body\}"
      Twilex.Messenger.send_sms(from, to, message)
    end
  end
  ```
  """

  @callback send_message(String.t(), String.t(), String.t(), String.t()) :: :ok | :error
end
