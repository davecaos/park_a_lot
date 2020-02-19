defmodule ParkaLot.API.Handlers.TicketsTest do
  use ExUnit.Case
  use ParkaLot.RepoCase
  
  alias ParkaLot.API.Handlers.Tickets

  @endpoint "/api/tickets"

  def hit_request_handle() do
    request = Raxx.request(:POST, @endpoint)
    |> ParkaLot.API.set_json_payload(%{})  

    Tickets.handle_request(request, %{})
  end
  
  test "when we hit endpoint #{@endpoint} must return a string with 16 digit Hex number" do
    response = hit_request_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => ticket_id_hexa}}} = Jason.decode(response.body)
    assert {id_in_decimal, _} = Integer.parse(ticket_id_hexa, 16)
    assert is_integer(id_in_decimal)
  end

  test "Every time we hit endpoint #{@endpoint} must return a autoincremental 16 digit Hex number" do

    incrementalNumbers = 
      Enum.map(1..10, 
        fn _ -> 
          response = hit_request_handle() 
          assert response.status == 200
          assert {"content-type", "application/json"} in response.headers
          assert {:ok, %{"data" => %{"id" => ticket_id_hexa}}} = Jason.decode(response.body)
          assert {id_in_decimal, _} = Integer.parse(ticket_id_hexa, 16)
          assert is_integer(id_in_decimal)
          id_in_decimal
        end)

      initialSeed = hd(incrementalNumbers) - 1
      {_, incrementalNumberChecks} =
        List.foldl( incrementalNumbers, {initialSeed, []}, fn current, {previous, acc} ->  check = (current == (previous + 1)); {current, [check | acc]}  end)
      assert Enum.all?(incrementalNumberChecks , fn(check) -> check == true end)
    
  end

end
