defmodule ParkaLot.API.Actions.ReturnTickets do
  alias ParkaLot.Maybe 
  alias ParkaLot.Entities.Tickets 
  alias ParkaLot.Tickets.Conversion
  alias ParkaLot.Entities.Singleton.AvailableSpace, as: SingletonAvailableSpace 

  def return_by(ticket_id) do

    with  {:ok, returned_ticket} <- Tickets.return_by(ticket_id),
          {:ok, _availabble_space} <- SingletonAvailableSpace.free_space() do
            Maybe.ok(render(returned_ticket))
    else       
      error -> error
    end
  end

  def render(ticket = %Tickets{id: ticket_id, inserted_at: inserted_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %Tickets{ticket | id: id_hexa16_with_padding}
  end
end
