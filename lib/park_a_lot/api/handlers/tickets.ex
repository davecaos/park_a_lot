defmodule ParkaLot.API.Handlers.Tickets do
  use Raxx.SimpleServer
  alias ParkaLot.API
  alias ParkaLot.API.Actions.Tickets

  @impl Raxx.SimpleServer

  def handle_request(_request = %{method: :POST}, _state) do
    case Tickets.create() do
      {:ok, ticket} ->  
        response(:ok)
        |> API.set_json_payload(%{data: ticket })

      _ ->  response(:error)
      end
  end

  def handle_request(_request = %{method: :GET, path: ["api", "tickets", ticket_id]}, _state) do
    case Tickets.get_by(ticket_id)  do
      {:ok, ticket} ->  
        response(:ok)
        |>  API.set_json_payload(%{data: ticket })

      {:error, error} -> 
        response(404)
        |> API.set_json_payload(%{errors: [error]})
      end
  end

end
