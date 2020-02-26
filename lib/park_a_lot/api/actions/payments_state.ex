defmodule ParkaLot.API.Actions.PaymentsState do
  alias ParkaLot.Entities.Constants, as: Constants
  alias ParkaLot.Entities.Tickets, as: Tickets
  alias ParkaLot.Maybe
  alias ParkaLot.Tickets.Conversion
  alias ParkaLot.Tickets.Datatypes.Time

  import Ecto.Query

  @in_seconds_limit_to_return_paid_ticket   Constants.in_seconds_15minutes

  def get_status(ticket_id) do
    with  {:ok, ticket_state= %{state: state, updated_at: updated_at}} <- Tickets.get_by(ticket_id) do
      payment_state = 
        cond do
          state == Constants.created_state  ->
            "unpaid"
          state == Constants.returned_state ->
            "paid"
          state == Constants.paid_state ->
            if is_it_is_penalized_by_overdue(updated_at), do: "unpaid", else: "paid"
          true ->
            "unpaid"
        end
    Maybe.ok(Map.merge(ticket_state, render(ticket_id, payment_state)))
    else
      error -> error
    end
  end

  defp is_it_is_penalized_by_overdue(updated_at) do
    Time.diff_date_and_now_in_seconds(updated_at) > @in_seconds_limit_to_return_paid_ticket 
  end

  def render(ticket_id, payment_state) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %{id: id_hexa16_with_padding, state: payment_state}
  end
end
