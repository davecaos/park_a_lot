defmodule ParkaLot.API.Actions.Tickets do
  alias ParkaLot.Entities
  alias  ParkaLot.Repo

  import Ecto.Query

  def create() do
    ticket =  %Entities.Tickets{}
    changeset = Entities.Tickets.changeset(ticket, %{})
    case Repo.insert(changeset) do
      {:ok, new_ticket} -> {:ok, render_to_ejson(new_ticket)}
      _ -> {:error, "Ticket not created"}
    end
  end

  def get_by(ticket_id) do
    {id_in_decimal, _} = Integer.parse(ticket_id, 16)
    query  = from(t in Entities.Tickets, where: t.id == ^id_in_decimal, select: t.id)

    case Repo.all(query) do
        nil -> {:error, "Not Found"}
        [id]  -> {:ok, render_to_ejson(id)}
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
      _ -> %{error: "Ticket not created"}
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
