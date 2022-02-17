defmodule ElfPay do
  alias ElfPay.{Orders, Payments}
  alias ElfPay.Orders.Order

  @moduledoc """
  ElfPay is an order and payment management system to be used by an online store
  for selling goods and services exclusively to Elves.
  This is the public context of ElfPay to be used by other systems and libraries.
  """

  @spec create_order(map()) :: %Order{} | nil
  def create_order(params) do
    Orders.create_order(params)
  end

  @spec get_order(integer()) :: %Order{} | {:error, String.t()}
  def get_order(id) do
    Orders.by_id(id)
  end

  @spec get_orders_for_customer(String.t()) :: list()
  def get_orders_for_customer(email) do
    Orders.by_customer_email(email)
  end

  @spec apply_payment_to_order(map()) :: {:ok, %Order{}} | {:error, atom(), map()}
  def apply_payment_to_order(params) do
    case Payments.create_payment(params) do
      {:error, attribute, error} -> {:error, attribute, error}
      {:ok, payment} -> {:ok, get_order(payment.order_id)}
    end
  end

  @spec create_order_and_pay(map()) :: {:ok, %Order{}} | {:error, :failure}
  def create_order_and_pay(params) do
    Orders.create_order_and_pay(params)
  end
end
