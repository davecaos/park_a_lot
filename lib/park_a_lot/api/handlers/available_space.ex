defmodule ParkaLot.API.Handlers.AvailableSpace do
  use Raxx.SimpleServer
  alias ParkaLot.API
  alias ParkaLot.API.Actions.AvailableSpace
  alias ParkaLot.Tickets.Conversion

  @impl Raxx.SimpleServer

  def handle_request(_request = %{method: :GET}, _state) do
    with {:ok, free_space} <- AvailableSpace.get_free_space() do
          response(:ok)
          |> API.set_json_payload(%{data: free_space })
    else
      {:error, reason}  ->
        response(400)
        |> API.set_json_payload(%{error: reason })
      _ ->
        response(:error)
    end
  end

end
