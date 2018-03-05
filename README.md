# TTFAuth
[![Build Status](https://travis-ci.org/Waasi/ttf_auth.svg?branch=master)](https://travis-ci.org/Waasi/ttf_auth)

TTFAuth is an Elixir OTP App for providing and managing temporary
access codes without Databases, just good old processes. [Docs](https://hexdocs.pm/ttf_auth/)

## Installation

```elixir
def deps do
  [
    {:ttf_auth, "~> 0.0.1"}
  ]
end
```

## Configuration

TTFAuth needs the configuration of the expiration time in milliseconds and
configure the sender module that TTFAuth will use to send the codes.

#### Example Configuration

```elixir
config :ttf_auth,
  expiration_time: 1200000 # 20 minutes,
  sender: MyApp.Messenger # Could send the codes via Twilio or Email using SMTP
```

Since the sender module is configurable it is only fair that it is extensible too.
Custom Messenger modules can be implemented using the messenger behavior.

#### Example Custom Messenger

```elixir
defmodule MyApp.Messenger do
  @behaviour TTFAuth.Messenger

  def send_message(from, to, body, code) do
    message = "use this code #{code} to #{body}"
    Twilex.Messenger.send_sms(from, to, message)
  end
end
```

For more info on the Messenger behaviour see: [Docs](https://hexdocs.pm/ttf_auth/TTFAuth.Messenger.html#content)

## Usage

TTFAuth is a 2 part funcionality application. First we need to use the
Dispatcher module to generate and send the access codes like this:

```elixir
# TTFAuth.Dispatcher.create_passport(entity, from, message)
TTFAuth.Dispatcher.create_passport("7875555555", "7874444444", "Welcome to MyApp")
{:ok, access_code}
```

The second part of the funcionality is using one of the 2 Sheriff Plugs Provided by TTFAuth
to authenticate request with TTFAuth access codes. The plugs will check if the access code
in the request is valid and if it is it will append the entity value as a private property
to the Plug.Conn structure for normal usage. For GraphQL it will appended in the context.
We can configure the plugs like this:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug TTFAuth.Plugs.Sheriff
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
    plug TTFAuth.Plugs.GQLSheriff
  end

  scope "/" do
    pipe_through :api
    forward "/", Absinthe.Plug, schema: MyAppWeb.Schema
  end
end
```

**Note: There are 2 important things to keep in mind when using TTFAuth

1. It is the developers responsibility, for now, to check if the request is authorized accessing the entity in Plug.Conn.
2. Every request made to the protected endpoints must have the authorization header with the value:
`<entity> <access>` with a space between values.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ttf_auth/fork )
2. Create your feature branch (`git checkout -b feature/my_new_feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
