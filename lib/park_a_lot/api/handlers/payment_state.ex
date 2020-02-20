defmodule ParkaLot.API.Handlers.PaymentsState do
  use Raxx.SimpleServer
  alias ParkaLot.API
  alias ParkaLot.API.Actions.PaymentsState
  alias ParkaLot.Tickets.Conversion

  @impl Raxx.SimpleServer

  def handle_request(_request = %{method: :GET, path: ["api", "tickets", barcode, "state"]}, _state) do
    with {:ok, ticket_id} <-  Conversion.to_id_from(barcode),
         {:ok, ticket} <- PaymentsState.get_status(ticket_id) do
          response(:ok)
          |> API.set_json_payload(%{data: ticket })
    else
      {:error, reason}  ->
        response(400)
        |> API.set_json_payload(%{error: reason })
      _ -> 
        response(:error)
    end
  end

end
