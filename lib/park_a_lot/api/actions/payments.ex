defmodule ParkaLot.API.Actions.Payments do
  alias ParkaLot.Entities.Tickets
  alias ParkaLot.Maybe
  alias ParkaLot.Repo
  alias ParkaLot.Entities.Constants, as: Constants
  alias ParkaLot.Entities.Tickets, as: Tickets
  alias ParkaLot.Tickets.Conversion
  alias ParkaLot.Tickets.Datatypes.Time

  import Ecto.Query

  def pay_by(ticket_id, payment_method) do
    case Tickets.get_by(ticket_id) do
      {:ok, ticket} -> 
        attributes = %{state: Constants.paid_state, payment_method: payment_method, updated_at: NaiveDateTime.utc_now()}
        result = 
          Tickets.changeset( ticket, attributes)
          |> Repo.update()

          case result do
            {:ok, new_ticket} -> {:ok, render(new_ticket)}
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


  def render(ticket = %Tickets{id: ticket_id, inserted_at: inserted_at}) do
    {:ok, id_hexa16_with_padding} = Conversion.to_hex_barcode_from(ticket_id) 
    %Tickets{ticket | id: :id_hexa16_with_padding}
  end

end
