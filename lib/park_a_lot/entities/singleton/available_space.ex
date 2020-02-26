defmodule ParkaLot.Entities.Singleton.AvailableSpace do
  alias ParkaLot.Repo
  alias ParkaLot.Maybe
  alias ParkaLot.Entities.Singleton.AvailableSpace, as: SAvailableSpace
  alias ParkaLot.Entities.Constants, as: Constants

  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
   
  @total_available_space Constants.total_available_space
  @singleton_intance_id  Constants.singleton_intance_id

    schema "available_space" do
      field :used_space, :integer
      timestamps()
    end

  @required_fields [:id, :used_space]


  def changeset(used_space, attrs \\ %{}) do
    used_space
    |> Ecto.Changeset.cast(attrs, @required_fields)
  end

  def allocate() do
    case get() do
      {:ok, @total_available_space} ->
        Maybe.error("There are NO slots available")
      {:ok, used_space } ->
        used_space = used_space + 1
        set(used_space )
        Maybe.ok(used_space)
      end
  end

  def free_space() do
    case SAvailableSpace.get() do
      {:ok, 0} ->
        Maybe.error("Empty Parking") #This should do no happen, but ...
      {:ok, used_space } ->
        used_space = used_space - 1
        set(used_space)
        Maybe.ok(used_space)
      end
  end
    
  def set2(used_space) do
    %SAvailableSpace{}
    |> SAvailableSpace.changeset( %{:id => @singleton_intance_id, :used_space => used_space})
    |> Repo.update()
  end

  def set(used_space) do
    sql = " INSERT INTO available_space (id,  used_space, inserted_at, updated_at)
            VALUES ($1 , $2, NOW(), NOW())
              ON CONFLICT (id) DO UPDATE
            SET (used_space, updated_at) = ($2, NOW())
            WHERE EXCLUDED.id = $1;"
           params = [ @singleton_intance_id, used_space]
    Ecto.Adapters.SQL.query(Repo, sql, params)
 end


  def get() do
    query = from(SAvailableSpace, where: [id: ^@singleton_intance_id], select: [:used_space])
    case Repo.all(query) do
      [] -> Maybe.error(:not_found)
      [%SAvailableSpace{used_space: used_space}] -> Maybe.ok(used_space)
    end
  end

  def get_free_space() do
    case get() do
      {:ok, used_space } ->
        ParkaLot.Maybe.ok( @total_available_space -  used_space)
      end
  end

  def total_available_space, do: @total_available_space
  
end
