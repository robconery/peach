defmodule Peach.Accounting.OrderFulfillment do
  defstruct [
    id: nil,
    key: nil,
    order_key: nil,
    message: nil,
    shipping_address: nil,
    order_items: [],
    customer_id: nil,
    customer_email: nil,
    customer_name: nil,
    status: "pending",
    logs: [],
    deliverables: [],
    created_at: nil
  ]
end
