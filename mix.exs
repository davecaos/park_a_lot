defmodule ParkaLot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :park_a_lot,
      version: "0.1.0",
      elixir: "~> 1.9.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases()
    ]
    |> Keyword.merge(custom_artifacts_directory_opts())
  end

  def application do
    [extra_applications: [:logger], mod: {ParkaLot.Application, []}]
  end

    # Specifies which paths to compile per environment.
    defp elixirc_paths(:test), do: ["lib", "test/support"]
    defp elixirc_paths(:dev), do: ["lib", "test/support"]
    defp elixirc_paths(_), do: ["lib"]


  defp deps do
    [
      {:ace, "~> 0.18.6"},
      {:raxx_logger, "~> 0.2.2"},
      {:jason, "~> 1.0"},
      {:exsync, "~> 0.2.3", only: :dev},
      {:postgrex, ">= 0.0.0"},
      {:ecto_sql, "~> 3.0.0"}
    ]
  end

  defp aliases() do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # makes sure that if the project is run by docker-compose inside a container,
  # its artifacts won't pollute the host's project directory
  defp custom_artifacts_directory_opts() do
    case System.get_env("MIX_ARTIFACTS_DIRECTORY") do
      unset when unset in [nil, ""] ->
        []
      directory ->
        [
          build_path: Path.join(directory, "_build"),
          deps_path: Path.join(directory, "deps")
        ]
    end
  end
end

