defmodule ParkaLot.API.Actions.Tickets do
  alias ParkaLot.Entities
  alias ParkaLot.Maybe
  alias ParkaLot.Repo

  import Ecto.Query

  @parking_cost_by_hour 2

  def create() do
    ticket =  %Entities.Tickets{}
    changeset = Entities.Tickets.changeset(ticket, %{})
    case Repo.insert(changeset) do
      {:ok, new_ticket} -> Maybe.ok(render_to_ejson(new_ticket))
      _ -> Maybe.error("Ticket not created")
    end
  end

  defp get_by(ticket_id_in_hexa) do
    case Integer.parse(ticket_id_in_hexa, 16) do
    {ticket_id_in_decimal, ""} ->
      query_by(ticket_id_in_decimal)
    _error ->
      Maybe.error("Invalid ticket id")
    end
  end

  defp query_by(ticket_id_in_decimal) do
    query  = from(t in Entities.Tickets, where: t.id == ^ticket_id_in_decimal, select: [t.id, t.inserted_at])

    case Repo.all(query) do
        [] -> Maybe.error("Ticket Not Found")
        [[id, inserted_at]]  -> {:ok, %{id: id, inserted_at: inserted_at}}
    end
  end

  defp calculate_parking_time_in_hours(ticket_id) do
    case get_by(ticket_id) do
      {:ok, ticket} -> 
        inserted_at = ticket.inserted_at
        now_in_seconds = DateTime.to_unix(DateTime.utc_now()) 
        ticket_created_in_seconds = DateTime.to_unix(DateTime.from_naive!(inserted_at, "Etc/UTC"))
        # now_in_seconds value should be greater than ticket_created_in_seconds time but if better to enforce that
        ticket_created_in_seconds = min(ticket_created_in_seconds, now_in_seconds)
        diff_in_seconds = now_in_seconds - ticket_created_in_seconds  
        hours = div(diff_in_seconds, 3600)
        started_hour = if rem(diff_in_seconds, 3600) == 0, do: 0, else: 1
        Maybe.ok(hours + started_hour)

      error -> error
    end
  end

  # a brand new ticket will cost at least 2€ after it was created
  defp minimum_parking_cost(cost) do
    max(@parking_cost_by_hour, cost)
  end

  def calculate_parking_costs(ticket_id) do
    case calculate_parking_time_in_hours(ticket_id) do
      {:ok, hours} -> 
        cost = minimum_parking_cost(hours * @parking_cost_by_hour)
        Maybe.ok( %{cost: cost}) 

      error -> error
    end
  end

  def delete(ticket_id) do
    soft_delete(ticket_id)
  end

  defp soft_delete(ticket_id) do
    {id_in_decimal, _} = Integer.parse(ticket_id, 16)
    result = Repo.get_by(Entities.Tickets, id: id_in_decimal)
      |> Entities.Tickets.changeset( %{deleted: :true})
      |> Repo.update()

    case result do
      {:ok, new_ticket} -> {:ok, render_to_ejson(new_ticket)}
      _ -> Maybe.error("Ticket not created")
    end
  end

  def render_to_ejson(%{id: ticket_id}) do
    render_to_ejson(ticket_id)
  end

  def render_to_ejson(ticket_id) do
    id_in_hexa16 = Integer.to_string(ticket_id, 16)
    padding_size = 16 - String.length(id_in_hexa16)
    padding = for _ <- 0..padding_size, do: '0'
    id_in_hexa16_with_padding = "#{padding}" <>  id_in_hexa16
    %{id: id_in_hexa16_with_padding }
  end

end
