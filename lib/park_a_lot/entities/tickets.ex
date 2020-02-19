defmodule ParkaLot.Entities.Tickets do
  alias ParkaLot.API
 
  use Ecto.Schema
  import Ecto.Changeset

  #@derive {Jason.Encoder, only: [:id]}

    schema "tickets" do
      # soft delete, keeping the history for auditing later
      field :deleted, :boolean
      timestamps()
    end

    def changeset(ticket, params) do
      ticket
      |> Ecto.Changeset.cast(params , [:deleted, :inserted_at])
    end

    def set_soft_delete(changeset, flag) do
      Ecto.Changeset.cast(changeset, %{deleted: flag})
    end

end
