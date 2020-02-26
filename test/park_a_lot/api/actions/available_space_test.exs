defmodule ParkaLot.API.Handlers.AvailableSpaceTest do
  use ExUnit.Case
  use ParkaLot.RepoCase

  alias ParkaLot.Entities
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.API.Handlers.AvailableSpace
  alias ParkaLot.Entities.Singleton.AvailableSpace, as: SingletonAvailableSpace


  def check_available_free_space_handler() do
    Raxx.request(:GET, "/api/free-spaces")
      |> AvailableSpace.handle_request(%{})
  end
  
  test "after the user created a ticket, that ticket must set the ticket as unpaid" do
    mock_used_space = 10
    SingletonAvailableSpace.set(mock_used_space)
    mock_available_free_space = SingletonAvailableSpace.total_available_space() - mock_used_space
    
    response = check_available_free_space_handler() 
    assert {:ok, %{"data" => %{"available_free_space" => mock_available_free_space}}} = Jason.decode(response.body)
  end

end
