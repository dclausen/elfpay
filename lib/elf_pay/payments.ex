defmodule ElfPay.Payments do
  alias ElfPay.Repo
  alias ElfPay.Payments.Payment
  alias ElfPay.Orders
  alias ElfPay.Orders.Order

  def create_payment(params) do
    case Orders.by_id(params[:order_id]) do
      nil -> {:error, :order, "invalid order_id"}
      order -> process_transaction(order, params)
    end
  end

  defp process_transaction(%Order{} = order, params) do
    case Ecto.Multi.new()
         |> Ecto.Multi.run(:process_payment, ElfPay.Payments, :process_payment, [params])
         |> Ecto.Multi.insert(:payment, Payment.changeset(params))
         |> Ecto.Multi.update(:order, Order.update_balance_changeset(order, params))
         |> Repo.transaction() do
      {:error, attribute, error, _} ->
        {:error, attribute, error}

      {:ok, response} ->
        {:ok,
         response[:payment]
         |> Repo.preload([:order, :customer])}
    end
  end

  def capture_payment(_attrs) do
    [:success, :success, :success, :failure] |> Enum.shuffle() |> hd()
  end

  def process_payment(_repo, _changes, attrs) do
    case capture_payment(attrs) do
      :success -> {:ok, :success}
      :failure -> {:error, :failure}
    end
  end
end
