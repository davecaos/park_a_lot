defmodule ParkaLot.API.Actions.ReturnTickets do
  alias ParkaLot.Maybe 
  alias ParkaLot.Entities.Tickets 
  alias ParkaLot.Tickets.Conversion
  alias ParkaLot.Entities.Constants, as: Constants
  alias ParkaLot.Entities.Singleton.AvailableSpace, as: SingletonAvailableSpace 

  @returned_state  Constants.returned_state

  def return_by(ticket_id) do

    with  {:ok, ticket} <- Tickets.get_by(ticket_id),
          {:ok, _ticket} <- validate_already_returned_ticket(ticket),
          {:ok, _availabble_space} <- SingletonAvailableSpace.free_space(),
          {:ok, updated_ticket} <- Tickets.update(ticket,  %{state: @returned_state, updated_at: NaiveDateTime.utc_now()} ) do
            Maybe.ok(render(updated_ticket))
    else       
      error -> error
    end
  end

  def render(ticket = %Tickets{id: ticket_id, inserted_at: inserted_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %Tickets{ticket | id: id_hexa16_with_padding}
  end

  defp validate_already_returned_ticket(%{state:  @returned_state}) do
    Maybe.error("Ticket already returned")
  end
  
  defp validate_already_returned_ticket(ticket) do
    Maybe.ok(ticket)
  end
end

