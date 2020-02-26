defmodule ParkaLot.API.Actions.Payments do
  alias ParkaLot.Entities.Tickets
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.Entities.Constants, as: Constants
  alias ParkaLot.Entities.Tickets, as: Tickets
  alias ParkaLot.Tickets.Conversion
  alias ParkaLot.Tickets.Datatypes.Time

  import Ecto.Query

  def pay_by(ticket_id, payment_method) do
    with  {:ok, new_ticket} <- Tickets.pay_by(ticket_id, payment_method) do
      Maybe.ok(render(new_ticket))
    else
      error -> error
    end
  end

  def render(ticket = %Tickets{id: ticket_id, inserted_at: inserted_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %Tickets{ticket | id: id_hexa16_with_padding}
  end

end
