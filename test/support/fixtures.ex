defmodule ElfPayTest.Fixtures do
  def unique_user_email, do: "user#{System.unique_integer([:positive])}@example.com"

  def customer_fixture(attrs \\ %{}) do
    customer_params = Enum.into(attrs, %{email: unique_user_email()})
    {:ok, customer} = ElfPay.Customers.create_customer(customer_params)

    customer
  end

  def order_fixture(attrs \\ %{}) do
    ElfPay.Orders.create_order(attrs)
  end
end
