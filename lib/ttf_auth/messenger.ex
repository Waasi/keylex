defmodule TTFAuth.Messenger do
  @callback send_message(String.t(), String.t(), String.t(), String.t()) :: :ok | :error
end
