defmodule ParkaLot.Repo.Migrations.CreateTickets do
  use Ecto.Migration
  @timestamps_opts [type: :utc_datetime]
  @primary_key {:id, :bigint, autogenerate: true}

  def change do
    create table(:tickets) do
      add :deleted, :boolean, default: false
      timestamps()
    end

  end
end
