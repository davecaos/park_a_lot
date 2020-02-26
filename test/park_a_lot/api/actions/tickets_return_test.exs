defmodule ParkaLot.API.Handlers.TicketsReturnTest do
  use ExUnit.Case
  use ParkaLot.RepoCase

  alias ParkaLot.Entities
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.API.Handlers.Tickets
  alias ParkaLot.Tickets.Datatypes.Time
  alias ParkaLot.API.Handlers.Payments
  alias ParkaLot.API.Handlers.ReturnTickets
  alias ParkaLot.API.Handlers.PaymentsState
  


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

  def hit_payments_state_handle(barcode) do
    request = Raxx.request(:GET, "/api/tickets/#{barcode}/state")
    PaymentsState.handle_request(request, %{})
  end

  def hit_ticket_return_state_handle(barcode) do
    request = Raxx.request(:POST, "/api/tickets/#{barcode}/return")
    |> ParkaLot.API.set_json_payload(%{}) 

    ReturnTickets.handle_request(request, %{})
  end


  test "after the user paid a ticket, that ticket must set the ticket as paid" do
    response = create_new_ticket_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode}}} = Jason.decode(response.body)
    assert {ticket_id, ""} = Integer.parse(bardcode, 16)
    assert is_integer(ticket_id)

    response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "unpaid"}}} = Jason.decode(response.body)


    response = hit_payments_handle(bardcode) 
    assert {:ok, %{"data" => %{"payment_method" => "cash","state" => "paid"}}} = Jason.decode(response.body)

    response_return_state = hit_ticket_return_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "returned"}}} = Jason.decode(response_return_state.body)

    response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "paid"}}} = Jason.decode(response.body)
  end

  test "after the user returned a ticket, every try to return the ticket again must arise an ERROR" do
    response = create_new_ticket_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode}}} = Jason.decode(response.body)
    assert {ticket_id, ""} = Integer.parse(bardcode, 16)
    assert is_integer(ticket_id)

    response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "unpaid"}}} = Jason.decode(response.body)


    response = hit_payments_handle(bardcode) 
    assert {:ok, %{"data" => %{"payment_method" => "cash","state" => "paid"}}} = Jason.decode(response.body)

    response_return_state = hit_ticket_return_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "returned"}}} = Jason.decode(response_return_state.body)

    response_error_return_state = hit_ticket_return_state_handle(bardcode) 
    assert {:ok, %{"error" => ["Ticket already returned"]}} = Jason.decode(response_error_return_state.body)
  end


  test "after LESS than 15 min than user paid a ticket, that ticket must set the ticket as PAID" do
    response = create_new_ticket_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode}}} = Jason.decode(response.body)
    assert {ticket_id, ""} = Integer.parse(bardcode, 16)
    assert is_integer(ticket_id)

    response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "unpaid"}}} = Jason.decode(response.body)

    response = hit_payments_handle(bardcode) 
    assert {:ok, %{"data" => %{"payment_method" => "cash","state" => "paid"}}} = Jason.decode(response.body)

    ticketEntity = Repo.get(Entities.Tickets, ticket_id) 
  
    fourteen_min_ago_in_seconds = 60*14 
    fourteen_min_ago_NDT = NaiveDateTime.add(NaiveDateTime.utc_now() , (- fourteen_min_ago_in_seconds))

    ticketEntity
    |> Entities.Tickets.changeset(%{updated_at: fourteen_min_ago_NDT})
    |> Repo.update()

    response_return_state = hit_ticket_return_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "returned"}}} = Jason.decode(response_return_state.body)
 
    state_response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "paid"}}} = Jason.decode(state_response.body)
  end

  test "after MORE than 4 hours than user RETURNED a ticket, that ticket must still set as PAID state" do
    now = NaiveDateTime.utc_now()
    response = create_new_ticket_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode}}} = Jason.decode(response.body)
    assert {ticket_id, ""} = Integer.parse(bardcode, 16)
    assert is_integer(ticket_id)

   
    response_payment_state = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "unpaid"}}} = Jason.decode(response_payment_state.body)

    response = hit_payments_handle(bardcode) 
     assert {:ok, %{"data" => %{"payment_method" => "cash","state" => "paid"}}} = Jason.decode(response.body)

    ticketEntity = Repo.get(Entities.Tickets, ticket_id) 
  
    four_hours_ago_in_seconds = 60*16 
    four_hours_ago_NDT = NaiveDateTime.add(now , (- four_hours_ago_in_seconds))

    ticketEntity
    |> Entities.Tickets.changeset(%{updated_at: four_hours_ago_NDT})
    |> Repo.update()

    response_return_state = hit_ticket_return_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "returned"}}} = Jason.decode(response_return_state.body)
 
    state_response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "paid"}}} = Jason.decode(state_response.body)
  end

end
