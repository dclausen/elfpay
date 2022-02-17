defmodule ElfPayTest do
  use ExUnit.Case, async: true
  use Patch
  import ElfPayTest.Fixtures

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ElfPay.Repo)
  end

  describe "create_order/1" do
    test "success: an order is created" do
      customer = customer_fixture()

      params = %{
        total: 100.00,
        customer_id: customer.id
      }

      order = ElfPay.create_order(params)
      refute order.order_number == nil
      assert order.customer.id == customer.id
      assert order.balance == 100.00
    end

    test "failure: no order is created for missing customer" do
      params = %{
        total: 100.00,
        customer_id: "1234"
      }

      assert {:error, "invalid customer_id"} = ElfPay.create_order(params)
    end
  end

  describe "get_order/1" do
    test "success: an existing order is returned" do
      customer = customer_fixture()
      order = order_fixture(%{total: 100.00, customer_id: customer.id})

      found_order = ElfPay.get_order(order.id)
      assert found_order.id == order.id
      assert found_order.payments == []
    end

    test "failure: does not return order if it doesn't exist" do
      order = ElfPay.get_order("123")
      assert order == nil
    end
  end

  describe "get_orders_for_customer/1" do
    test "success: orders for an existing customer are returned" do
      customer = customer_fixture()
      order = order_fixture(%{total: 100.00, customer_id: customer.id})

      found_orders = ElfPay.get_orders_for_customer(customer.email)
      assert Enum.count(found_orders) == 1
      assert Enum.map(found_orders, & &1.id) == [order.id]
    end

    test "failure: no orders returned for nonexistant customer" do
      customer = customer_fixture()
      order_fixture(%{total: 100.00, customer_id: customer.id})

      found_orders = ElfPay.get_orders_for_customer("nope@test.com")
      assert Enum.count(found_orders) == 0
    end
  end

  describe "apply_payment_to_order/2" do
    test "success: multiple payments are applied to existing order" do
      customer = customer_fixture()
      order = order_fixture(%{total: 100.00, customer_id: customer.id})
      params = %{amount: 10.00, nonce: Ecto.UUID.generate(), order_id: order.id}
      patch(ElfPay.Payments, :capture_payment, fn _ -> :success end)

      assert order.payments == []
      {:ok, updated_order} = ElfPay.apply_payment_to_order(params)
      assert Enum.count(updated_order.payments) == 1
      assert Decimal.eq?(updated_order.balance, Decimal.from_float(90.00))

      {:ok, updated_order} =
        ElfPay.apply_payment_to_order(%{params | nonce: Ecto.UUID.generate()})

      assert Enum.count(updated_order.payments) == 2
      assert Decimal.eq?(updated_order.balance, Decimal.from_float(80.00))
    end

    test "failure: payment is not applied if nonce already exists" do
      customer = customer_fixture()
      nonce = Ecto.UUID.generate()
      order = order_fixture(%{total: 100.00, customer_id: customer.id})
      params = %{amount: 10.00, nonce: nonce, order_id: order.id}
      patch(ElfPay.Payments, :capture_payment, fn _ -> :success end)

      assert order.payments == []
      {:ok, updated_order} = ElfPay.apply_payment_to_order(params)
      assert Enum.count(updated_order.payments) == 1

      {:error, :payment, _} = ElfPay.apply_payment_to_order(params)
      assert Enum.count(updated_order.payments) == 1
      assert Decimal.eq?(updated_order.balance, Decimal.from_float(90.00))
    end

    test "failure: payment is not applied if order doesn't exist" do
      customer = customer_fixture()
      order = order_fixture(%{total: 100.00, customer_id: customer.id})
      params = %{amount: 10.00, nonce: Ecto.UUID.generate(), order_id: "123"}

      assert order.payments == []
      assert {:error, :order, "invalid order_id"} = ElfPay.apply_payment_to_order(params)
      same_order = ElfPay.Orders.by_id(order.id)
      assert Decimal.eq?(same_order.balance, Decimal.from_float(100.00))
    end
  end

  describe "create_order_and_pay" do
    test "successful payment capture: order and payment are created" do
      customer = customer_fixture()
      params = %{amount: 10.00, nonce: Ecto.UUID.generate(), customer_id: customer.id}
      patch(ElfPay.Payments, :capture_payment, fn _ -> :success end)

      {:ok, order} = ElfPay.create_order_and_pay(params)
      assert Decimal.eq?(order.total, Decimal.from_float(params[:amount]))
      assert Enum.count(order.payments) == 1
      assert Decimal.eq?(order.balance, Decimal.from_float(0.0))
    end

    test "failed payment capture: order and payment are not created" do
      customer = customer_fixture()
      params = %{amount: 10.00, nonce: Ecto.UUID.generate(), customer_id: customer.id}
      patch(ElfPay.Payments, :capture_payment, fn _ -> :failure end)

      {:error, :process_payment, :failure} = ElfPay.create_order_and_pay(params)
      assert Enum.count(ElfPay.Orders.by_customer_id(customer.id)) == 0
    end
  end
end
