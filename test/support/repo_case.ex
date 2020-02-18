defmodule ParkaLot.RepoCase do
  use ExUnit.CaseTemplate
  # SEE https://hexdocs.pm/ecto/testing-with-ecto.html for more information

  using do
    quote do
       alias ParkaLot.Repo

       import Ecto
       import Ecto.Query
       import ParkaLot.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ParkaLot.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ParkaLot.Repo, {:shared, self()})
    end

    :ok
  end
end

