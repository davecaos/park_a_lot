defmodule ParkaLot.API.Actions.AvailableSpace do
  alias ParkaLot.Entities.Singleton.AvailableSpace, as: SingletonAvailableSpace 
  alias ParkaLot.Maybe

  def get_free_space() do
    with  {:ok, free_space} <- SingletonAvailableSpace.get_free_space(),
          json_render <- render(free_space) do
            Maybe.ok(json_render) 
    else            
      error -> error
    end
  end

  def render(free_space) do
    %{:available_free_space => free_space}
  end
end
