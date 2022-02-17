defmodule ElfPay.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElfPay.Customers.Customer
  alias ElfPay.Orders
  alias ElfPay.Orders.Order

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "payments" do
    field(:amount, :decimal)
    field(:nonce, :string)
    belongs_to(:customer, Customer)
    belongs_to(:order, Order)
    timestamps()
  end

  def changeset(params) do
    case Orders.by_id(params[:order_id]) do
      nil ->
        %__MODULE__{}
        |> change()
        |> add_error(:order_id, "is not valid")

      order ->
        %__MODULE__{}
        |> change()
        |> put_change(:order_id, order.id)
        |> put_change(:customer_id, order.customer.id)
        |> cast(params, [:amount, :nonce, :order_id, :customer_id])
        |> validate_required([:amount, :nonce, :order_id, :customer_id])
        |> unique_constraint([:nonce, :customer_id])
    end
  end
end
