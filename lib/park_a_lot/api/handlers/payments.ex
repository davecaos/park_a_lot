defmodule ParkaLot.API.Handlers.Payments do
  use Raxx.SimpleServer
  alias ParkaLot.API
  alias ParkaLot.API.Actions.Payments
  alias ParkaLot.Tickets.Conversion

  @impl Raxx.SimpleServer

  def handle_request(request = %{method: :POST, path: ["api", "tickets", barcode, "payments"]}, _state) do
    with {:ok, ticket_id} <-  Conversion.to_id_from(barcode),
         {:ok,  %{"payment_method" =>  pay_method}} <- Jason.decode(request.body),
         {:ok, ticket} <- Payments.pay_by(ticket_id, pay_method) do
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
