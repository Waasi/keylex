defmodule Keylex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :keylex,
      version: "0.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      source_url: "https://github.com/Waasi/keylex",
      package: package(),
      docs: [extras: ["README.md"]]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Keylex.Application, []}
    ]
  end

  defp deps, do: [{:plug, "~> 1.0"}, {:ex_doc, ">= 0.0.0", only: :dev}]

  defp description do
    "Keylex is an Elixir OTP App for providing and managing temporary access codes without Databases, just good old processes."
  end

  defp package do
    [name: :keylex,
     files: ["lib", "config", "mix.exs", "LICENSE*"],
     maintainers: ["Eric Santos"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/Waasi/keylex"}]
  end
end
