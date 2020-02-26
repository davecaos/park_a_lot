defmodule ParkaLot.API.Handlers.PaymentsTest do
  use ExUnit.Case
  use ParkaLot.RepoCase

  alias ParkaLot.Entities
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.API.Handlers.Tickets
  alias ParkaLot.API.Handlers.Payments

  @endpoint "/api/tickets"

  def create_new_ticket_handle() do
    request = Raxx.request(:POST, "/api/tickets")
    |> ParkaLot.API.set_json_payload(%{})  

    Tickets.handle_request(request, %{})
  end

  def hit_payments_handle(barcode) do
    request = Raxx.request(:POST, "/api/tickets/#{barcode}/payments")
    |> ParkaLot.API.set_json_payload(%{"payment_method" => "cash"})  

    Payments.handle_request(request, %{})
  end
  
  test "when we hit endpoint payments endpoint , this must set the ticket as paid" do
    response = create_new_ticket_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode_hexa}}} = Jason.decode(response.body)
    assert {ticket_id, ""} = Integer.parse(bardcode_hexa, 16)
    assert is_integer(ticket_id)

    response = hit_payments_handle(bardcode_hexa) 
    assert {:ok, %{"data" => %{"id" => bardcode_hexa, "payment_method" => "cash", "state" => "paid"}}} = Jason.decode(response.body)
  end

  test "After the user paid a ticket, this must cost 0" do
    response = create_new_ticket_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode_hexa}}} = Jason.decode(response.body)
    assert {ticket_id, ""} = Integer.parse(bardcode_hexa, 16)
    assert is_integer(ticket_id)

    response = hit_payments_handle(bardcode_hexa) 
    assert {:ok, %{"data" => %{"id" => bardcode_hexa, "payment_method" => "cash", "state" => "paid"}}} = Jason.decode(response.body)

    cost_request = Raxx.request(:GET, "/api/tickets/#{bardcode_hexa}")
    cost_response = Tickets.handle_request(cost_request, %{})
    assert cost_response.status == 200
    already_paid_ticket_cost = 0
    assert {:ok, %{"data" => %{"cost" => already_paid_ticket_cost}}} = Jason.decode(cost_response.body)
  end

  test "After the user paid a ticket, every try to paid the ticket again must arise an ERROR" do
    response = create_new_ticket_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode_hexa}}} = Jason.decode(response.body)
    assert {ticket_id, ""} = Integer.parse(bardcode_hexa, 16)
    assert is_integer(ticket_id)

    response = hit_payments_handle(bardcode_hexa) 
    assert {:ok, %{"data" => %{"id" => bardcode_hexa, "payment_method" => "cash", "state" => "paid"}}} = Jason.decode(response.body)

    error_response = hit_payments_handle(bardcode_hexa) 
    assert {:ok, %{"error" => "Ticket already paid"}} = Jason.decode(error_response.body)
  end

end
