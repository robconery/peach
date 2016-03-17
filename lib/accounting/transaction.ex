defmodule Peach.Accounting.Transaction do
  alias __MODULE__

  defstruct [
    key: UUID.uuid4(),
    order_key: nil,
    processor: nil,
    payment: nil,
    processor_response: nil,
    amount_due: 0.00,
    amount_paid: 0.00
  ]

  def create_from_stripe_response(order: order, payment: payment, response: response) do
    %Transaction{
      order_key: order.key,
      processor: "stripe",
      payment: payment,
      processor_response: response,
      amount_due: order.summary.subtotal,
      amount_paid: response.amount
    }
  end
end
