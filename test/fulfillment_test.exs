defmodule Peach.FulfillmentTest do
  use ExUnit.Case
  alias Peach.Fulfillment
  alias Peach.Sales
  import Plug.Conn

  @order_args key: "test"
  @item sku: "honeymoon-mars", quantity: 1

  @payment %{card: %{address_city: "Boca Raton",
          address_country: "United States", address_line1: "93293 Thi",
          address_line1_check: "pass", address_line2: "", address_state: "FL",
          address_zip: "33433", address_zip_check: "pass", brand: "Visa",
          country: "US", cvc_check: "pass", dynamic_last4: "", exp_month: "12",
          exp_year: "2019", funding: "unknown", id: "card_7yAj4icmWrQYyQ",
          last4: "1111", name: "Heavy Larry", object: "card",
          tokenization_method: ""}, client_ip: "73.140.245.24",
        created: "1456365469", email: "rob@conery.io", id: "tok_7yAjmK8BlCoPxh",
        livemode: "false", object: "token", type: "card", used: "false"}

  @response %{amount: 92900, amount_refunded: 0, application_fee: nil,
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

  setup do

    conn = %Plug.Conn{}
          |> fetch_cookies
          |> Peach.Store.call
          |> Sales.empty_items
          |> Sales.select_item(sku: "honeymoon-mars", quantity: 1)
          |> Sales.record_sale(payment: @payment, processor: "stripe", response: @response)

    #Peach.Store.fulfill_order conn.assigns.order

    {:ok, order: conn.assigns.order}
  end

  test "deliverables are set", %{order: order} do
    order = order |> Fulfillment.prepare_delivery
    assert length(order.deliverables) == length(order.items)
  end

  # test "an invoice is created and nothing is nil", %{order: order}  do
  #   invoice = Processor.create_invoice "fulfillment_test"
  #   nils_present = Enum.any? Map.values(invoice), &(&1 == nil)
  #   refute nils_present
  # end
  #
  # test "a customer email is sent" do
  #
  # end

end
