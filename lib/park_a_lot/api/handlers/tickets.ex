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

        {:error, error} -> 
          response(:ok)
          |> API.set_json_payload(%{error: [error]})

          _error -> 
            response(:error)
      end
  end

  def handle_request(request = %{method: :GET, path: ["api", "tickets", barcode]}, state) do
    with {:ok, ticket_id} <-  Conversion.to_id_from(barcode),
         {:ok, cost} <- Tickets.parking_costs_by(ticket_id)  do 
            response(:ok)
            |>  API.set_json_payload(%{data: cost })
    else
        {:error, error} -> 
          response(:ok)
          |> API.set_json_payload(%{error: [error]})

        _error -> 
          response(:error)
    end
  end

end
