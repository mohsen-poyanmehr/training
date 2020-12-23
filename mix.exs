defmodule Router.MixProject do
  use Mix.Project

  def project do
    [
      app: :router,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :ewebmachine],
      mod: {Router.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:cowboy, "~> 1.1.2"},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.3.4"},
      # {:plug, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:exfsm, git: "https://github.com/kbrw/exfsm.git"},
      {:ewebmachine, "~> 2.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
