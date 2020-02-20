defmodule ParkaLot.Entities.Tickets do
  alias ParkaLot.Entities.Tickets
 
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:paid, :payment_method, :paid_at, :inserted_at]}

    schema "tickets" do
      # soft delete, keeping the history for auditing later
      field :paid, :boolean
      field :payment_method, :string
      field :paid_at, :utc_datetime
      timestamps()
    end

    def changeset(ticket, attrs \\ %{}) do
      ticket
      |> Ecto.Changeset.cast(attrs, [:paid, :payment_method, :paid_at, :inserted_at])
    end

    def set_soft_delete(changeset, flag) do
      Ecto.Changeset.cast(changeset, %{deleted: flag})
    end

end
