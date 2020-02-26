defmodule ParkaLot.API.Actions.Payments do
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.Entities.Constants, as: Constants
  alias ParkaLot.Entities.Tickets, as: Tickets
  alias ParkaLot.Tickets.Conversion
  alias ParkaLot.Tickets.Datatypes.Time

  import Ecto.Query

  @paid_state Constants.paid_state

  def pay_by(ticket_id, payment_method) do
    with  {:ok, ticket} <- Tickets.get_by(ticket_id),
          {:ok, _ticket} <- validate_already_paid_ticket(ticket),
          {:ok, updated_ticket} <- Tickets.update(ticket,  %{state: Constants.paid_state, payment_method: payment_method, updated_at: NaiveDateTime.utc_now()}) do
            Maybe.ok(render(updated_ticket))
    else
      error -> error
    end
  end

  def render(ticket = %{id: ticket_id, inserted_at: inserted_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %Tickets{ticket | id: id_hexa16_with_padding}
  end

  defp validate_already_paid_ticket(%{state: @paid_state}) do
    Maybe.error("Ticket already paid")
  end

  defp validate_already_paid_ticket(ticket) do
    Maybe.ok(ticket)
  end


end
