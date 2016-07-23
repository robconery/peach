defmodule Peach.OrderTest do
  use ExUnit.Case
  import Plug.Conn
  alias Peach.Sales
  alias Peach.Db.Postgres, as: Db

  @order_args key: "test"
  @item sku: "honeymoon-mars", quantity: 1

  setup do
    "delete from orders" |> Db.run

    conn = %Plug.Conn{}
          |> fetch_cookies
          |> Peach.Store.call
          |> Sales.empty_items

    {:ok, conn: conn}
  end

  test "a order is created using conn", %{conn: conn} do
    conn = conn |> Sales.current
    assert conn.assigns.order.id
  end

  test "It adds an item", %{conn: conn} do
    conn = Sales.select_item(conn, sku: "illudium-q36", quantity: 1)
    assert length(conn.assigns.order.items) == 1
  end

  test "Adding multiple items", %{conn: conn} do
    conn = Sales.select_item(conn, sku: "illudium-q36", quantity: 1)
    conn = Sales.select_item(conn, sku: "johnny-liftoff", quantity: 1)

    assert length(conn.assigns.order.items) == 2
  end

  test "Adding multiple items and changing second to qty 5", %{conn: conn} do
    conn = conn
      |> Sales.select_item(sku: "illudium-q36", quantity: 1)
      |> Sales.select_item(sku: "johnny-liftoff", quantity: 1)
      |> Sales.change_item(sku: "johnny-liftoff", quantity: 5)

    assert length(conn.assigns.order.items) == 2
  end

  test "It won't add an item that doesn't exist", %{conn: conn} do
    conn = Sales.select_item conn, sku: "poop", quantity: 1
    assert length(conn.assigns.order.items) == 0
    assert conn.assigns.order.message == "That item doesn't exist in our catalog"
  end

  test "quantity, name, price and sku are set", %{conn: conn} do
    conn = Sales.select_item(conn, @item)
    assert length(conn.assigns.order.items) == 1

    conn = Sales.select_item conn, @item
    assert length(conn.assigns.order.items) == 1
    first = List.first(conn.assigns.order.items)
    assert first.quantity == 2
    assert first.name == "Honeymoon on Mars"
    assert first.price == 1233200
  end

  test "It increments quantity when item exists", %{conn: conn} do
    conn = Sales.select_item(conn, @item)
    assert length(conn.assigns.order.items) == 1

    conn = Sales.select_item conn, @item
    assert length(conn.assigns.order.items) == 1
    first = List.first(conn.assigns.order.items)
    assert first.quantity == 2
  end

  test "it removes an item", %{conn: conn} do
    conn =  Sales.select_item conn, @item
    assert length(conn.assigns.order.items) == 1
    conn = Sales.remove_item conn, sku: "honeymoon-mars"
    assert length(conn.assigns.order.items) == 0
  end

  test "it removes an item with conn", %{conn: conn} do
    conn =  Sales.select_item conn, @item
    assert length(conn.assigns.order.items) == 1
    conn = Sales.remove_item conn, sku: "honeymoon-mars"
    assert length(conn.assigns.order.items) == 0
  end

  test "a summary is returned", %{conn: conn} do
    conn = conn
      |> Sales.select_item(@item)
      |> Sales.select_item(@item)

    order = conn.assigns.order

    assert order.summary.item_count == 2
    assert order.summary.subtotal == 2466400
    assert order.summary.total == 2466400
  end


  test "changing quantities", %{conn: conn} do
    conn = conn
      |> Sales.select_item(@item)
      |> Sales.change_item(sku: "honeymoon-mars", quantity: 12)
    first = List.first(conn.assigns.order.items)
    assert first.quantity == 12
  end

  test "removing an item not in the cart results in an error", %{conn: conn} do
    conn = Sales.remove_item conn, sku: "pop"
    assert conn.assigns.order.message == "SKU 'pop' not found in the cart"
  end

  test "changing quantity of a sku not there results in error", %{conn: conn} do
    conn = Sales.change_item conn, sku: "asdasd", quantity: 12
    assert conn.assigns.order.message == "SKU 'asdasd' not found in the cart"
  end

  test "using a nil sku for add returns error", %{conn: conn} do
    case Sales.select_item conn, sku: nil do
      {:error, mssg} -> assert mssg
      _ -> flunk "Should have received an error"
    end
  end

  test "sending 0 to add returns an error", %{conn: conn} do
    case Sales.select_item conn, sku: "honeymoon-mars", quantity: 0 do
      {:error, mssg} -> assert mssg
      _ -> flunk "Should have received an error"
    end
  end

  test "sending negative number to add returns an error", %{conn: conn} do
    case Sales.select_item conn, sku: "honeymoon-mars", quantity: -3 do
      {:error, mssg} -> assert mssg
      _ -> flunk "Should have received an error"
    end
  end

  test "using a nil sku for conn.assigns returns error", %{conn: conn} do
    case Sales.change_item conn, sku: nil do
      {:error, mssg} -> assert mssg
      _ -> flunk "Should have received an error"
    end
  end

  test "using a nil sku for remove returns error", %{conn: conn} do
    case Sales.remove_item conn, sku: nil do
      {:error, mssg} -> assert mssg
      _ -> flunk "Should have received an error"
    end
  end

  test "it records a sale", %{conn: conn} do
    payment =  %{card: %{address_city: "Boca Raton",
          address_country: "United States", address_line1: "93293 Thi",
          address_line1_check: "pass", address_line2: "", address_state: "FL",
          address_zip: "33433", address_zip_check: "pass", brand: "Visa",
          country: "US", cvc_check: "pass", dynamic_last4: "", exp_month: "12",
          exp_year: "2019", funding: "unknown", id: "card_7yAj4icmWrQYyQ",
          last4: "1111", name: "Heavy Larry", object: "card",
          tokenization_method: ""}, client_ip: "73.140.245.24",
        created: "1456365469", email: "rob@conery.io", id: "tok_7yAjmK8BlCoPxh",
        livemode: "false", object: "token", type: "card", used: "false"}

    response =  %{amount: 92900, amount_refunded: 0, application_fee: nil,
      balance_transaction: "txn_7yAjbHNrzJnR3l", captured: true,
      created: 1456365472, currency: "usd", customer: nil, description: nil,
      destination: nil, dispute: nil, failure_code: nil, failure_message: nil,
      fraud_details: %{}, id: "ch_7yAjebowHZ0qZn", invoice: nil, livemode: false,
      metadata: %{}, object: "charge", order: nil, paid: true,
      receipt_email: "rob@conery.io", receipt_number: nil, refunded: false,
      refunds: %{data: [], has_more: false, object: "list", total_count: 0,
        url: "/v1/charges/ch_7yAjebowHZ0qZn/refunds"}, shipping: nil,
      source: %{address_city: "Boca Raton", address_country: "United States",
        address_line1: "93293 Thi", address_line1_check: "pass",
        address_line2: nil, address_state: "FL", address_zip: "33433"},
      statement_descriptor: nil, status: "succeeded"}

    conn = conn
      |> Sales.record_sale(payment: payment, processor: "stripe", response: response)
    order = conn.assigns.order

    assert order.invoice
    assert order.payment
    assert order.payment.processor == "stripe"
    assert order.payment.response

  end

  test "it stops the order on close", %{conn: conn} do
    payment =  %{card: %{address_city: "Boca Raton",
          address_country: "United States", address_line1: "93293 Thi",
          address_line1_check: "pass", address_line2: "", address_state: "FL",
          address_zip: "33433", address_zip_check: "pass", brand: "Visa",
          country: "US", cvc_check: "pass", dynamic_last4: "", exp_month: "12",
          exp_year: "2019", funding: "unknown", id: "card_7yAj4icmWrQYyQ",
          last4: "1111", name: "Heavy Larry", object: "card",
          tokenization_method: ""}, client_ip: "73.140.245.24",
        created: "1456365469", email: "rob@conery.io", id: "tok_7yAjmK8BlCoPxh",
        livemode: "false", object: "token", type: "card", used: "false"}

    response =  %{amount: 92900, amount_refunded: 0, application_fee: nil,
      balance_transaction: "txn_7yAjbHNrzJnR3l", captured: true,
      created: 1456365472, currency: "usd", customer: nil, description: nil,
      destination: nil, dispute: nil, failure_code: nil, failure_message: nil,
      fraud_details: %{}, id: "ch_7yAjebowHZ0qZn", invoice: nil, livemode: false,
      metadata: %{}, object: "charge", order: nil, paid: true,
      receipt_email: "rob@conery.io", receipt_number: nil, refunded: false,
      refunds: %{data: [], has_more: false, object: "list", total_count: 0,
        url: "/v1/charges/ch_7yAjebowHZ0qZn/refunds"}, shipping: nil,
      source: %{address_city: "Boca Raton", address_country: "United States",
        address_line1: "93293 Thi", address_line1_check: "pass",
        address_line2: nil, address_state: "FL", address_zip: "33433"},
      statement_descriptor: nil, status: "succeeded"}

    conn = conn
      |> Sales.record_sale(payment: payment, processor: "stripe", response: response)
      |> Sales.close


    assert :global.whereis_name({:order_key, conn.assigns.order.key}) == :undefined
  end

end
