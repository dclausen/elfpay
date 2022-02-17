defmodule ElfPay.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :order_number, :string, null: false
      add :total, :decimal, null: false
      add :balance, :decimal, null: false
      add :customer_id, references(:customers)

      timestamps()
    end

    create index(:orders, [:customer_id])
    create unique_index(:orders, [:order_number])
  end
end
