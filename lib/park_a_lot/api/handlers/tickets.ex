defmodule ParkaLot.API.Handlers.Tickets do
  use Raxx.SimpleServer
  alias ParkaLot.API
  alias ParkaLot.API.Actions.Tickets
  alias ParkaLot.Tickets.Conversion

  @impl Raxx.SimpleServer

  def handle_request(_request = %{method: :POST, path: ["api", "tickets"]}, _state) do
    case Tickets.create() do
      {:ok, ticket} ->  
        response(:ok)
        |> API.set_json_payload(%{data: ticket })

      _ ->  response(400)
      end
  end

  def handle_request(_request = %{method: :GET, path: ["api", "tickets", barcode]}, _state) do
    with {:ok, ticket_id} <-  Conversion.to_id_from(barcode),
         {:ok, cost} <- Tickets.parking_costs_by(ticket_id)  do 
            response(:ok)
            |>  API.set_json_payload(%{data: cost })
    else
        {:error, error} -> 
          response(404)
          |> API.set_json_payload(%{error: [error]})
    end
  end

end
