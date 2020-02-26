defmodule ParkaLot.Entities.Tickets do

  alias ParkaLot.Repo
  alias ParkaLot.Maybe
  alias ParkaLot.Entities.Tickets
  alias ParkaLot.Entities.Constants, as: Constants

  use Ecto.Schema
  import Ecto.Changeset
  
  @derive {Jason.Encoder, only: [ :id, :payment_method, :state, :inserted_at ]}

  @paid_state Constants.paid_state
  @returned_state  Constants.returned_state
  @singleton_intance_id  Constants.singleton_intance_id

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

    defp update(ticket, attributes) do
      Tickets.changeset(ticket, attributes)
      |> Repo.update()
    end

    def get_by(ticket_id) do
      case Repo.get(Tickets, ticket_id) do
          nil -> Maybe.error("Ticket Not Found")
          ticket -> Maybe.ok(ticket)
      end
    end

    def pay_by(ticket_id, payment_method) do
      case get_by(ticket_id) do
        {:ok, %{state: @paid_state}} ->
          Maybe.error("Ticket already paid")
        {:ok, ticket} -> 
          attributes = %{state: Constants.paid_state, payment_method: payment_method, updated_at: NaiveDateTime.utc_now()}
          update(ticket, attributes)
        
        error -> error
      end
    end

    def return_by(ticket_id) do
      case get_by(ticket_id) do
        {:ok, %{state: @returned_state} } ->
          Maybe.error("Ticket already returned")
        {:ok, ticket} -> 
          attributes = %{state: @returned_state, updated_at: NaiveDateTime.utc_now()} 
          update(ticket, attributes)
          
        error -> error
      end
    end

end
