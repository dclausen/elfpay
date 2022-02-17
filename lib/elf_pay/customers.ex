defmodule ElfPay.Customers do
  alias ElfPay.Repo
  alias ElfPay.Customers.Customer

  def create_customer(params) do
    Customer.changeset(params)
    |> Repo.insert()
  end

  def by_id(id) do
    Repo.get(Customer, id)
    |> Repo.preload(:orders)
  end

  def by_email(email) do
    Repo.get_by(Customer, email: email)
    |> Repo.preload(orders: [:customer, :payments])
  end
end
