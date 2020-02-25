defmodule ParkaLot.API.Handlers.ReturnTickets do
  use Raxx.SimpleServer

  alias ParkaLot.API
  alias ParkaLot.Tickets.Conversion

  @impl Raxx.SimpleServer

  def handle_request(%{ path: ["api", "tickets", barcode, "return"]}, _state) do
    with {:ok, ticket_id} <-  Conversion.to_id_from(barcode),
         {:ok, returned_ticket} <- ParkaLot.API.Actions.ReturnTickets.return_by(ticket_id)  do 
            response(:ok)
            |>  API.set_json_payload(%{data: returned_ticket })
    else
        {:error, error} -> 
          response(404)
          |> API.set_json_payload(%{error: [error]})
    end
  end

end
