defmodule ParkaLot.API.Handlers.Payments do
  use Raxx.SimpleServer
  alias ParkaLot.API
  alias ParkaLot.Maybe
  alias ParkaLot.API.Actions.Payments
  alias ParkaLot.Tickets.Conversion

  @impl Raxx.SimpleServer

  def handle_request(request = %{ path: ["api", "tickets", barcode, "payments"]}, _state) do
    with {:ok, ticket_id} <-  Conversion.to_id_from(barcode),
         {:ok, ejson} <- decode_body(request.body),
         {:ok,  %{"payment_method" =>  pay_method}} <- validate_payment_method_in(ejson),
         {:ok, ticket} <- Payments.pay_by(ticket_id, pay_method) do
          response(:ok)
          |> API.set_json_payload(%{data: ticket })
    else
      {:error, reason}  ->
        response(:ok)
        |> API.set_json_payload(%{error: reason })
      _ -> 
        response(:error)
    end
  end

  def decode_body(body) do
    case String.length(body) do
      0 ->
        Maybe.error("The Json body is mandatory")
      _WhenOthers ->
        Jason.decode(body)
    end
  end

    def validate_payment_method_in(ejson) do
      case Map.keys(ejson) do
        ["payment_method"] -> Maybe.ok(ejson)
        _-> Maybe.error("The Json's payment_method field is mandatory")
      end

    end

end
