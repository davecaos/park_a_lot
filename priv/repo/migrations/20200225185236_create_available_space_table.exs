defmodule ParkaLot.Repo.Migrations.CreateAvailableSpaceTable do
  use Ecto.Migration

  alias ParkaLot.Entities.Singleton.AvailableSpace, as: SingletonAvailableSpace
  @timestamps_opts [type: :utc_datetime]

    def change do
  
      create table(:available_space) do
        add :used_space, :integer, default: 0
        timestamps()
      end
    end

end
