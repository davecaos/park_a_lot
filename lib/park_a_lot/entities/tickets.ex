defmodule ParkaLot.Entities.Tickets do

  alias ParkaLot.Repo
  alias ParkaLot.Maybe
  alias ParkaLot.Entities.Tickets
  alias ParkaLot.Entities.Constants, as: Constants

  use Ecto.Schema
  import Ecto.Changeset
  
  @derive {Jason.Encoder, only: [ :id, :payment_method, :state, :inserted_at ]}

    schema "tickets" do
      field :state, :string
      field :payment_method, :string
      timestamps()
    end

    def changeset(ticket, attrs \\ %{}) do
      ticket
      |> Ecto.Changeset.cast(attrs, [:id,:state, :payment_method, :inserted_at, :updated_at])
    end

    def create() do
      %Tickets{}
      |> Tickets.changeset(%{:state => Constants.created_state})
      |> Repo.insert()
    end

    def get_by(ticket_id) do
      case Repo.get(Tickets, ticket_id) do
          nil -> Maybe.error("Ticket Not Found")
          ticket -> Maybe.ok(ticket)
      end
    end

    def return_by(ticket_id) do
      case Repo.get(Tickets, ticket_id) do
        nil -> Maybe.error("Ticket not found")
        ticket -> 
          attributes = %{state: Constants.returned_state, updated_at: NaiveDateTime.utc_now()} 
          Tickets.changeset( ticket, attributes)
            |> Repo.update()
      end
    end



end
