defmodule ParkaLot.API.Actions.ReturnTickets do
  alias ParkaLot.Maybe 
  alias ParkaLot.Entities.Tickets 
  alias ParkaLot.Entities.Singleton.AvailableSpace, as: SingletonAvailableSpace 

  def return_by(ticket_id) do

    with  {:ok, returned_ticket} <- Tickets.return_by(ticket_id),
          {:ok, _availabble_space} <- SingletonAvailableSpace.free_space() do
            Maybe.ok(returned_ticket)
    else       
      error -> error
    end
  end

end
