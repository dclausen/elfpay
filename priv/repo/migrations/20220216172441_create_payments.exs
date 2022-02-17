defmodule ElfPay.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :amount, :decimal, null: false
      add :nonce, :string, null: false
      add :customer_id, references(:customers)
      add :order_id, references(:orders)

      timestamps()
    end

    create index(:payments, [:customer_id])
    create index(:payments, [:order_id])
    create unique_index(:payments, [:nonce, :customer_id])
  end
end
