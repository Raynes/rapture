defmodule Rapture.Mixfile do
  use Mix.Project

  def project do
    [ app: :rapture,
      version: "0.1.4",
      elixir: "~> 0.10.0",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [{:reap, "~> 0.1.2", github: "Raynes/reap", tag: "v0.1.2"},
     {:etoml, "~> 0.1", github: "kalta/etoml"}]
  end
end
