defmodule ParkaLot.API.Handlers.NotFound do
  use Raxx.SimpleServer
  alias ParkaLot.API

  @impl Raxx.SimpleServer
  def handle_request(_request, _state) do
    error = %{reason: "Not found Path"}

    response(:not_found)
    |> API.set_json_payload(%{errors: [error]})
  end
end
