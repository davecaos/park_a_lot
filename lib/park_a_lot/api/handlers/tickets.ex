defmodule ParkaLot.API.Handlers.Tickets do
  use Raxx.SimpleServer
  alias ParkaLot.API
  alias ParkaLot.API.Actions.Tickets

  @impl Raxx.SimpleServer

  def handle_request(_request = %{method: :POST, path: ["api", "tickets"]}, _state) do
    case Tickets.create() do
      {:ok, ticket} ->  
        response(:ok)
        |> API.set_json_payload(%{data: ticket })

      _ ->  response(:error)
      end
  end

  def handle_request(_request = %{method: :GET, path: ["api", "tickets", barcode]}, _state) do
    case Tickets.parking_costs_by(barcode)  do
      {:ok, cost} ->  
        response(:ok)
        |>  API.set_json_payload(%{data: cost })

      {:error, error} -> 
        response(404)
        |> API.set_json_payload(%{error: [error]})
      end
  end

end
