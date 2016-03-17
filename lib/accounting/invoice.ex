defmodule Peach.Accounting.Invoice do
  import Peach.Util

  defstruct [
    id: nil,
    key: UUID.uuid4(),
    order_key: nil,
    bill_to: nil,
    email: nil,
    ship_to: nil,
    billing_address: nil,
    shipping_address: nil,
    items: [],
    discounts: [],
    status: "open",
    amount_due: 0.00,
    amount_paid: 0.00,
    paid_at: nil,
    payment: nil,
    ip: nil
  ]

  def create_from_stripe_response(order: order, payment: payment, response: response) do
    %Peach.Accounting.Invoice{
      bill_to: payment["token"]["card"]["name"],
      email: order.customer_email,
      ship_to: order.customer_name,
      billing_address: %{
        street: payment["token"]["card"]["address_line1"],
        city: payment["token"]["card"]["address_city"],
        state: payment["token"]["card"]["address_state"],
        zip: payment["token"]["card"]["address_zip"],
        country: payment["token"]["card"]["country"],
      },
      shipping_address: order.address,
      items: order.items,
      discounts: order.discounts,
      status: "paid",
      amount_due: order.summary.subtotal,
      amount_paid: response.amount,
      order_key: order.key,
      ip: payment["client_ip"],
      paid_at: now_iso,
      payment: payment
    }
  end

end
