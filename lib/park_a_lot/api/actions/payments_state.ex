defmodule ParkaLot.API.Actions.PaymentsState do
  alias ParkaLot.Entities.Tickets
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.Tickets.Conversion

  import Ecto.Query

  @parking_cost_by_hour 2

  defp get_by(ticket_id_in_dec) do
   
    case Repo.get(Tickets, ticket_id_in_dec) do
        nil -> Maybe.error("Ticket Not Found")
        ticket -> Maybe.ok(ticket)
    end
  end

  def get_status(ticket_id) do
    #TODO
    Maybe.ok(%{:status => "unpaid"})
  end

  def diff_time_between_paid_ticket_now_in_minutes_by(ticket_id) do
    case get_by(ticket_id) do
      {:ok, ticket =%{paid_at: "unpaid"}} -> 
        Maybe.ok(%{ticket_state | state: :unpaid} )
      {:ok, ticket} -> 
        paid_at= ticket.paid_at
        now_in_seconds = DateTime.to_unix(DateTime.utc_now()) 
        ticket_paid_at_in_seconds = DateTime.to_unix(DateTime.from_naive!(paid_at, "Etc/UTC"))  
        # now_in_seconds value should be greater than ticket_created_in_seconds time but if better to enforce that
        ticket_paid_at_in_seconds = min(ticket_paid_at_in_seconds, now_in_seconds)
        diff_in_seconds = now_in_seconds - ticket_paid_at_in_seconds  
        hours = div(diff_in_seconds, 3600)
        ticket_state = if rem(diff_in_seconds, 60) > 15, do: :unpaid, else: :paid
        Maybe.ok(%{ticket | state: ticket_state} )

      error -> error
    end
  end


  def render_to_ejson(ticket = %{id: ticket_id, inserted_at: inserted_at, paid: paid, paid_at: paid_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %{id: id_hexa16_with_padding, inserted_at: inserted_at, paid: paid, paid_at: paid_at}
  end

end
