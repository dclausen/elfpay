defmodule ElfPay.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElfPay.Customers.Customer
  alias ElfPay.Payments.Payment
  alias ElfPay.Orders.Order

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "orders" do
    field(:total, :decimal)
    field(:order_number, :string)
    field(:balance, :decimal)
    belongs_to(:customer, Customer)
    has_many(:payments, Payment)
    timestamps()
  end

  def insert_changeset(%Customer{} = customer, params) do
    %__MODULE__{}
    |> change()
    |> put_assoc(:customer, customer)
    |> cast(params, [:total, :customer_id])
    |> add_order_number()
    |> put_change(:balance, params[:total])
    |> validate_required([:total, :customer_id])
    |> unique_constraint(:order_number)
  end

  def update_balance_changeset(%Order{} = order, params) do
    order
    |> change()
    |> put_change(:balance, new_balance(order, Decimal.from_float(params[:amount])))
  end

  defp add_order_number(%Ecto.Changeset{} = changeset) do
    changeset |> put_change(:order_number, unique_order_number())
  end

  defp unique_order_number do
    for _ <- 1..8, into: "", do: <<Enum.random('0123456789ABCDEF')>>
  end

  defp new_balance(%Order{} = order, amount) do
    updated =
      Enum.reduce(order.payments, amount, fn payment, acc ->
        Decimal.add(acc, payment.amount)
      end)

    Decimal.sub(order.total, updated)
  end
end
