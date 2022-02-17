defmodule ElfPay.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElfPay.Orders.Order

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "customers" do
    field(:email, :string)
    has_many(:orders, Order)
    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
