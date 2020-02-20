defmodule ParkaLot.API.Actions.PaymentsState do
  alias ParkaLot.Entities.Tickets
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.Tickets.Conversion

  import Ecto.Query

  @parking_cost_by_hour 2

  defp get_by(ticket_id_in_dec) do
   
    case Repo.get(Tickets, ticket_id_in_dec) do
        nil -> Maybe.error("Ticket Not Found")
        ticket -> Maybe.ok(ticket)
    end
  end

  def get_status(ticket_id) do

    with  {:ok, ticket_state} <- get_by(ticket_id),
          {:ok, is_paid} <-  Map.fetch(ticket_state, :paid) do
            payment_state = if is_paid, do: "paid", else: "unpaid"
            Maybe.ok( Map.merge(ticket_state, %{state: payment_state}))
    else
          error -> error
    end
  end


  def render_to_ejson(ticket = %{id: ticket_id, inserted_at: inserted_at, paid: paid, paid_at: paid_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %{id: id_hexa16_with_padding, inserted_at: inserted_at, paid: paid, paid_at: paid_at}
  end

end
