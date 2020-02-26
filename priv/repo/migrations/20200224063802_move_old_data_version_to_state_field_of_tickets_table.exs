defmodule ParkaLot.Repo.Migrations.MoveOldDataVersionToStateFieldOfTicketsTable do
  use Ecto.Migration

  alias ParkaLot.Repo
  alias ParkaLot.Entities.Constants, as: Constants
  alias ParkaLot.Entities.Tickets, as: Tickets 

  import Ecto.Query

  def up do
    query = from(  t in Tickets, select: t) 

    alter table(:tickets) do
      remove :paid
      remove :paid_at
    end

    Repo.all(query)
    |> Enum.map(fn t -> Tickets.changeset(t, migrate_ticket(t)) end)
    |> Enum.map(&Repo.update/1)

  end

  def down do
    
  end

  defp migrate_ticket(_ticket = %{paid: true, paid_at: paid_at}) do
      %{:status => Constants.paid_state, :update_at =>  paid_at}
  end

  defp migrate_ticket(_ticket= %{paid_at: paid_at}) do
    %{:status => Constants.created_state, :update_at => paid_at}
  end
end


