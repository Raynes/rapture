defmodule Rapture.Mixfile do
  use Mix.Project

  def project do
    [ app: :rapture,
      version: "0.1.5",
      deps: deps,
      escript_main_module: Rapture]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [{:reap, "~> 0.1.3"},
     {:hackney, ">= 0.4.2", github: "benoitc/hackney", ref: "05c5aa94b8fc18050d210292de09307254804b82"},
     {:etoml, github: "kalta/etoml"}]
  end
end
