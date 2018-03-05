defmodule TTFAuth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ttf_auth,
      version: "0.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      source_url: "https://github.com/Waasi/ttf_auth",
      package: package(),
      docs: [extras: ["README.md"]]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TTFAuth.Application, []}
    ]
  end

  defp deps, do: [{:plug, "~> 1.0"}, {:ex_doc, ">= 0.0.0", only: :dev}]

  defp description do
    "TTFAuth is an Elixir OTP App for providing and managing temporary access codes without Databases, just good old processes."
  end

  defp package do
    [name: :ttf_auth,
     files: ["lib", "config", "mix.exs", "LICENSE*"],
     maintainers: ["Eric Santos"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/Waasi/ttf_auth"}]
  end
end
