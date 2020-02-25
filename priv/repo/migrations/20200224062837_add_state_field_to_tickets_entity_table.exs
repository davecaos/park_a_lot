defmodule ParkaLot.Repo.Migrations.AddStateFieldToTicketsEntityTable do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      add :state, :string, default: nil
    end
  end
end
