defmodule ParkaLot.Repo.Migrations.AddPaidAndPaymentMethodFieldsToTicketsTable do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      remove_if_exists :deleted, :boolean
      add :paid, :boolean, default: false
      add :payment_method, :string, null: true
      add :paid_at, :utc_datetime, default: fragment("null")
    end
  end

end
