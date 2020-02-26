defmodule ParkaLot.API.Actions.Tickets do

  alias ParkaLot.Entities.Tickets, as: ETickets
  alias ParkaLot.Entities.Constants, as: Constants
  alias ParkaLot.Maybe
  alias ParkaLot.Tickets.Conversion
  alias ParkaLot.Tickets.Datatypes.Time
  alias ParkaLot.Entities.Singleton.AvailableSpace, as: SingletonAvailableSpace

  import Ecto.Query

  def create() do
    with  {:ok, new_ticket} <- ETickets.create(),
          {:ok, _} <- SingletonAvailableSpace.allocate() do
            Maybe.ok(render(new_ticket))
    else
       _ -> 
        Maybe.error("Ticket not created")
    end
  end

  defp diff_time_between_ticket_now_in_hours_by(ticket_id) do
    case ETickets.get_by(ticket_id) do
      {:ok, _ticket = %{state: "paid" }} -> 
        Maybe.ok(0)

      {:ok, ticket} -> 
        diff_in_seconds = Time.diff_date_and_now_in_seconds(ticket.inserted_at)
        hours = div(diff_in_seconds, 3600)
        started_hour = if rem(diff_in_seconds, 3600) == 0, do: 0, else: 1
        Maybe.ok(hours + started_hour)

      error -> error
    end
  end

  # a brand new ticket will cost at least 2€ after it was created
  defp minimum_parking_cost(cost) do
    max(Constants.parking_cost_by_hour, cost)
  end

  def parking_costs_by(ticket_id) do
    case diff_time_between_ticket_now_in_hours_by(ticket_id) do
      {:ok, hours} -> 
        cost = hours * Constants.parking_cost_by_hour
        Maybe.ok( %{cost: cost, currency: Constants.currency}) 

      error -> error
    end
  end


  def render(ticket = %{id: ticket_id, inserted_at: inserted_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %{id: id_hexa16_with_padding, inserted_at: inserted_at}
  end

end
