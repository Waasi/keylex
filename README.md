# Keylex
[![Build Status](https://travis-ci.org/Waasi/keylex.svg?branch=master)](https://travis-ci.org/Waasi/keylex)

Keylex is an Elixir OTP App for providing and managing temporary
access codes without Databases, just good old processes. [Docs](https://hexdocs.pm/keylex/)

## Installation

```elixir
def deps do
  [
    {:keylex, "~> 0.0.1"}
  ]
end
```

## Configuration

Keylex needs the configuration of the expiration time in milliseconds and
configure the sender module that Keylex will use to send the codes.

#### Example Configuration

```elixir
config :keylex,
  expiration_time: 1200000 # 20 minutes,
  sender: MyApp.Messenger # Could send the codes via Twilio or Email using SMTP
```

Since the sender module is configurable it is only fair that it is extensible too.
Custom Messenger modules can be implemented using the messenger behavior.

#### Example Custom Messenger

```elixir
defmodule MyApp.Messenger do
  @behaviour Keylex.Messenger

  def send_message(from, to, body, code) do
    message = "use this code #{code} to #{body}"
    Twilex.Messenger.send_sms(from, to, message)
  end
end
```

For more info on the Messenger behaviour see: [Docs](https://hexdocs.pm/keylex/Keylex.Messenger.html#content)

## Usage

Keylex is a 2 part funcionality application. First we need to use the
Dispatcher module to generate and send the access codes like this:

```elixir
# Keylex.Dispatcher.create_passport(entity, from, message)
Keylex.Dispatcher.create_passport("7875555555", "7874444444", "Welcome to MyApp")
{:ok, access_code}
```

The second part of the funcionality is using one of the 2 Sheriff Plugs Provided by Keylex
to authenticate request with Keylex access codes. The plugs will check if the access code
in the request is valid and if it is it will append the entity value as a private property
to the Plug.Conn structure for normal usage. For GraphQL it will appended in the context.
We can configure the plugs like this:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Keylex.Plugs.Sheriff
  end

  scope "/" do
    pipe_through :api

    # routes definitions go here
  end
end
```

For GraphQL Support with Absinthe do:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Keylex.Plugs.GQLSheriff
  end

  scope "/" do
    pipe_through :api
    forward "/", Absinthe.Plug, schema: MyAppWeb.Schema
  end
end
```

**Note: There is 1 important thing to keep in mind when using Keylex

1. Every request made to the protected endpoints must have the authorization header with the value:
`<entity> <access>` with a space between values.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/keylex/fork )
2. Create your feature branch (`git checkout -b feature/my_new_feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
