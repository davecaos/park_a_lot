defmodule ParkaLot.API.Handlers.TicketsTest do
  use ExUnit.Case
  use ParkaLot.RepoCase

  alias ParkaLot.Entities
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
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
    assert {:ok, %{"data" => %{"id" => bardcode_hexa}}} = Jason.decode(response.body)
    assert {id_in_decimal, ""} = Integer.parse(bardcode_hexa, 16)
    assert is_integer(id_in_decimal)
  end

  test "Every time we hit endpoint #{@endpoint} must return a autoincremental 16 digit Hex number" do
    incrementalNumbers = 
      Enum.map(1..10, 
        fn _ -> 
          response = hit_request_handle() 
          assert response.status == 200
          assert {"content-type", "application/json"} in response.headers
          assert {:ok, %{"data" => %{"id" => bardcode_hexa}}} = Jason.decode(response.body)
          assert {id_in_decimal, ""} = Integer.parse(bardcode_hexa, 16)
          assert is_integer(id_in_decimal)
          id_in_decimal
        end)

      initialSeed = hd(incrementalNumbers) - 1
      {_, incrementalNumberChecks} =
        List.foldl( incrementalNumbers, {initialSeed, []}, fn current, {previous, acc} ->  check = (current == (previous + 1)); {current, [check | acc]}  end)
      assert Enum.all?(incrementalNumberChecks , fn(check) -> check == true end)
    
  end

  test "When we create a ticket, their cost at the moment must be 2 euros" do
    response = hit_request_handle() 
    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode_hexa}}} = Jason.decode(response.body)
    

    cost_request = Raxx.request(:GET, "/api/tickets/#{bardcode_hexa}")
    cost_response = Tickets.handle_request(cost_request, %{})
    assert cost_response.status == 200
    minimal_ticket_cost = 2
    assert {:ok, %{"data" => %{"cost" => minimal_ticket_cost}}} = Jason.decode(cost_response.body)

  end

  test "When we search a barcode that does not exist" do
    bardcode_hexa_do_no_exist = "EFFFFFFFFFFFF"

    cost_request = Raxx.request(:GET, "/api/tickets/#{bardcode_hexa_do_no_exist}")
    cost_response = Tickets.handle_request(cost_request, %{})
    assert cost_response.status == 404  
    assert {:ok, %{"error" => _reason}} = Jason.decode(cost_response.body)

  end

  test "Check the cost of parking for 4 complete hours (4 hs + you current" do
    now = NaiveDateTime.utc_now()

    ticket =  %Entities.Tickets{}
    changeset = Entities.Tickets.changeset(ticket, %{})
    assert {:ok, new_ticket}  = Repo.insert(changeset)
    assert %{id: ticket_id} = new_ticket
    barcode = Integer.to_string(ticket_id, 16)
    cost_request = Raxx.request(:GET, "/api/tickets/#{barcode}")

    four_hours_ago_in_seconds = 60*60*4 
    four_hours_ago_plus_minute_in_seconds = four_hours_ago_in_seconds + 60
    four_hours_ago_NDT = NaiveDateTime.add(now , (- four_hours_ago_plus_minute_in_seconds))
    new_ticket
      |> Entities.Tickets.changeset(%{inserted_at: four_hours_ago_NDT})
      |> Repo.update()
 
    
    
    cost_response = Tickets.handle_request(cost_request, %{})
    assert cost_response.status == 200
    assert {:ok, %{"data" => %{"cost" => 10}}} = Jason.decode(cost_response.body)

  end



end
