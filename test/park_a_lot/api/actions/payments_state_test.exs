defmodule ParkaLot.API.Handlers.PaymentsStateTest do
  use ExUnit.Case
  use ParkaLot.RepoCase

  alias ParkaLot.Entities
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.API.Handlers.Tickets
  alias ParkaLot.Tickets.Datatypes.Time
  alias ParkaLot.API.Handlers.Payments
  alias ParkaLot.API.Handlers.PaymentsState

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

  def hit_payments_state_handle(barcode) do
    request = Raxx.request(:GET, "/api/tickets/#{barcode}/state")
 

    PaymentsState.handle_request(request, %{})
  end
  
  test "after the user created a ticket, that ticket must set the ticket as unpaid" do
    response = create_new_ticket_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode}}} = Jason.decode(response.body)
    assert {ticket_id, ""} = Integer.parse(bardcode, 16)
    assert is_integer(ticket_id)

    response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "unpaid"}}} = Jason.decode(response.body)

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
    assert {:ok, %{"data" => %{"paid" => true}}} = Jason.decode(response.body)

    response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "paid"}}} = Jason.decode(response.body)
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
    assert {:ok, %{"data" => %{"paid" => true}}} = Jason.decode(response.body)

    ticketEntity = Repo.get(Entities.Tickets, ticket_id) 
  
    fourteen_min_ago_in_seconds = 60*14 
    fourteen_min_ago_NDT = NaiveDateTime.add(NaiveDateTime.utc_now() , (- fourteen_min_ago_in_seconds))

    ticketEntity
    |> Entities.Tickets.changeset(%{paid_at: fourteen_min_ago_NDT})
    |> Repo.update()

  
    response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "paid"}}} = Jason.decode(response.body)
  end

  test "after MORE than 15 min than user paid a ticket, that ticket must set the ticket as UNPAID" do
    response = create_new_ticket_handle() 

    assert response.status == 200
    assert {"content-type", "application/json"} in response.headers
    assert {:ok, %{"data" => %{"id" => bardcode}}} = Jason.decode(response.body)
    assert {ticket_id, ""} = Integer.parse(bardcode, 16)
    assert is_integer(ticket_id)

    response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "unpaid"}}} = Jason.decode(response.body)

    response = hit_payments_handle(bardcode) 
    assert {:ok, %{"data" => %{"paid" => true}}} = Jason.decode(response.body)

    ticketEntity = Repo.get(Entities.Tickets, ticket_id) 
  
    sixteen_min_ago_in_seconds = 60*16 
    sixteen_min_ago_NDT = NaiveDateTime.add(NaiveDateTime.utc_now() , (- sixteen_min_ago_in_seconds))

    ticketEntity
    |> Entities.Tickets.changeset(%{paid_at: sixteen_min_ago_NDT})
    |> Repo.update()

  
    response = hit_payments_state_handle(bardcode) 
    assert {:ok, %{"data" => %{"state" => "unpaid"}}} = Jason.decode(response.body)
  end

end
