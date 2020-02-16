use Mix.Config


config :park_a_lot,
  ecto_repos: [ParkaLot.Repo]

config :park_a_lot, ParkaLot.Repo,
  # it can be overridden using the DATABASE_URL environment variable
  url: "ecto://PLDRUnl8:HAJHZE6SkpHkxaJEZO@localhost:6543/park_a_lot?ssl=false&pool_size=10"

if Mix.env() == :test do
config :park_a_lot, ParkaLot.Repo,
  pool: Ecto.Adapters.SQL.Sandbox
end


if Mix.env() == :dev do
  config :exsync,
    extra_extensions: [".js", ".css"]
end

