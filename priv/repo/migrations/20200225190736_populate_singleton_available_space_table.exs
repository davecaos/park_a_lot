defmodule ParkaLot.Repo.Migrations.PopulateSingletonAvailableSpaceTable do
  use Ecto.Migration
  alias ParkaLot.Entities.Singleton.AvailableSpace, as: SingletonAvailableSpace
  alias ParkaLot.Repo

  import Ecto.Query

  def change do
    initial_used_space = 0
    singleton =  %SingletonAvailableSpace{}
    changeset = SingletonAvailableSpace.changeset(singleton, %{:id =>1, :used_space => initial_used_space})
    {:ok, _} = Repo.insert(changeset)
  end

end
