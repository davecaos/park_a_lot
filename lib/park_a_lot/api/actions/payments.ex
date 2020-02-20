defmodule ParkaLot.API.Actions.Payments do
  alias ParkaLot.Entities.Tickets
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.Tickets.Conversion

  import Ecto.Query

  @parking_cost_by_hour 2

  def pay_by(ticket_id, payment_method) do
    case Repo.get(Tickets, ticket_id) do
      nil -> Maybe.error("Ticket not found")
      ticket -> 
        attributes = %{paid: true, payment_method: payment_method, paid_at: NaiveDateTime.utc_now()}
        result = Tickets.changeset( ticket, attributes)
          |> Repo.update()

          case result do
            {:ok, new_ticket} -> {:ok, render_to_ejson(new_ticket)}
            _ -> Maybe.error("Ticket not created")
          end
      
      error -> error
    end
  end



  defp get_by(ticket_id_in_dec) do
   
    case Repo.get(Tickets, ticket_id_in_dec) do
        nil -> Maybe.error("Ticket Not Found")
        ticket -> Maybe.ok(ticket)
    end
  end


  defp diff_time_between_ticket_now_in_hours_by(ticket_id) do
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


  def render_to_ejson(ticket = %{id: ticket_id, inserted_at: inserted_at, paid: paid, paid_at: paid_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %{id: id_hexa16_with_padding, inserted_at: inserted_at, paid: paid, paid_at: paid_at}
  end

end
