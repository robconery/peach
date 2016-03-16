defmodule Peach.Accounting.SalesOrder do
  use GenServer
  import Peach.Util
  alias Peach.Sales.CartItem
  alias Peach.Db.Postgres, as: Db
  alias __MODULE__
  import Plug.Conn

  defstruct [
     store_id: nil,
     customer_id: nil,
     status: "open",
     customer_name: "Rorb Conery",
     customer_email: "rob@conery.io",
     address: %{street: "PO Box 803", street2: nil, city: "Hanalei", state: "HI", zip: "96714", country: "USA"},
     id: nil,
     key: nil,
     landing: "/",
     message: nil,
     ip: "127.0.0.1",
     items: [],
     history: [],
     transactions: [],
     invoice: nil,
     payment: nil,
     summary: %{item_count: 0, total: 0.00, subtotal: 0.0},
     logs: [%{entry: "order Created", date: now_iso}],
     discounts: [],
     deliverables: []
   ]

   def summarize(order) do
     Enum.reduce order.items, %{item_count: 0, subtotal: 0, total: 0}, fn(item,acc) ->
       quantity = item.quantity + acc.item_count
       subtotal = (item.price * item.quantity) + acc.subtotal
       total =  ((item.price-item.discount) * item.quantity) + acc.total
       %{item_count: quantity, subtotal: subtotal, total: total}
     end
   end

   def add_log_entry(order, entry) do
     %{order | message: entry, logs: List.insert_at(order.logs, -1, %{entry: entry, date: now_iso})}
   end


   def remove_item({:new, %{order: order, new_item: %{sku: sku}}}), do: handle_error(order, "SKU '#{sku}' not found in the cart")
   def remove_item({:found, %{order: order, existing: item}}) do
     order = %{order | items: List.delete(order.items, item)}
     {:ok, order: order, log: "#{item.sku} removed from cart"}
   end

   def change_quantity({:new, %{order: order, new_item: %{sku: sku}}}, _), do: handle_error(order, "SKU '#{sku}' not found in the cart")
   def change_quantity({:found, %{order: order, existing: item} = located}, quantity: new_quantity) do
     items = update_items(located, %{quantity: new_quantity})
     order = %{order | items: items}
     {:ok, order: order, log: "#{item.sku} updated to #{new_quantity}"}
   end

   def add_item({:new, %{order: order, new_item: item}}) do
     order = %{order | items: List.insert_at(order.items, -1, item)}
     {:ok, order: order, log: "#{item.sku} added to cart"}
   end

   def add_item({:found, %{order: order, existing: existing, new_item: item} = located}) do
     new_quantity = existing.quantity + item.quantity
     order = %{order | items: update_items(located, %{quantity: new_quantity})}
     {:ok, order: order, log: "#{item.sku} updated to #{new_quantity}"}
   end

   def update_items(%{order: order, idx: idx, existing: existing}, %{quantity: val}) do
     new_item = %{existing | quantity: val}
     List.replace_at(order.items, idx, new_item)
   end

   def locate_item(order, %{sku: sku} = item) do
     case  Enum.find_index(order.items, &(&1.sku == sku)) do
       nil -> {:new, %{order: order, new_item: item}}
       idx -> {:found, %{order: order, idx: idx, existing: Enum.at(order.items, idx), new_item: item}}
     end
   end

   defp handle_error(order, mssg) do
     {:error, order: order, message: mssg}
   end
end
