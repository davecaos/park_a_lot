defmodule ParkaLot.API.Actions.PaymentsState do
  alias ParkaLot.Entities.Tickets
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.Tickets.Conversion
  alias ParkaLot.Tickets.Datatypes.Time

  import Ecto.Query

  @parking_cost_by_hour 2

  defp get_by(ticket_id) do
   
    case Repo.get(Tickets, ticket_id) do
        nil -> Maybe.error("Ticket Not Found")
        ticket -> Maybe.ok(ticket)
    end
  end

  def get_status(ticket_id) do
    with  {:ok, ticket_state= %Tickets{paid: is_paid, paid_at: paid_at}} <- get_by(ticket_id) do
      payment_state = 
        cond do
          is_paid == false ->
            "unpaid"
          is_paid == true ->
            if is_it_is_penalized_by_overdue(paid_at), do: "unpaid", else: "paid"
        end
      Maybe.ok( Map.merge(ticket_state, %{state: payment_state}))
    else
          error -> error
    end
  end

  defp is_it_is_penalized_by_overdue(paid_at) do
    Time.diff_date_and_now_in_seconds(paid_at) > Time.in_seconds_15minutes
  end

  def render_to_ejson(ticket = %Tickets{id: ticket_id, inserted_at: inserted_at, paid: paid, paid_at: paid_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %{id: id_hexa16_with_padding, inserted_at: inserted_at, paid: paid, paid_at: paid_at}
  end

end
