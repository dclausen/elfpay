defmodule ElfPay.Orders do
  alias ElfPay.Repo
  alias ElfPay.Orders.Order
  alias ElfPay.Customers
  alias ElfPay.Payments.Payment

  def create_order(params) do
    case Customers.by_id(params[:customer_id]) do
      nil ->
        {:error, "invalid customer_id"}

      customer ->
        {:ok, order} =
          Order.insert_changeset(customer, params)
          |> Repo.insert()

        order
        |> Repo.preload([:customer, :payments])
    end
  end

  def by_id(id) do
    Repo.get(Order, id)
    |> Repo.preload([:customer, :payments])
  end

  def by_customer_email(email) do
    case Customers.by_email(email) do
      nil -> []
      customer -> customer.orders
    end
  end

  def by_customer_id(id) do
    case Customers.by_id(id) do
      nil -> []
      customer -> customer.orders
    end
  end

  def create_order_and_pay(params) do
    order_params = %{total: params[:amount], customer_id: params[:customer_id]}
    payment_params = %{amount: params[:amount], nonce: params[:nonce]}

    case Ecto.Multi.new()
         |> Ecto.Multi.run(:customer, fn _repo, _ ->
           case Customers.by_id(params[:customer_id]) do
             nil -> {:error, "invalid customer_id"}
             customer -> {:ok, customer}
           end
         end)
         |> Ecto.Multi.run(:order, fn _repo, _ ->
           case create_order(order_params) do
             {:error, error} -> {:error, error}
             order -> {:ok, order}
           end
         end)
         |> Ecto.Multi.run(:process_payment, ElfPay.Payments, :process_payment, [payment_params])
         |> Ecto.Multi.insert(:payment, fn %{order: order} ->
           Payment.changeset(Map.put(payment_params, :order_id, order.id))
         end)
         |> Ecto.Multi.update(:order_balance, fn %{order: order} ->
           Order.update_balance_changeset(order, params)
         end)
         |> Repo.transaction() do
      {:error, attribute, error, _} ->
        {:error, attribute, error}

      {:ok, response} ->
        {:ok, by_id(response[:order].id)}
    end
  end
end
