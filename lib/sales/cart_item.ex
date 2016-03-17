defmodule Peach.Sales.CartItem do
  import Peach.Util
  alias __MODULE__

  defstruct [
    store_id: nil,
    options: nil,
    sku: nil,
    quantity: 1,
    price: 0.00,
    name: nil,
    description: nil,
    image: nil,
    discount: 0.00,
    created_at: now_iso,
    vendor: nil,
    requires_shipping: false,
    downloadable: false
  ]
  def create_from_product(nil, _quantity), do: nil
  def create_from_product(%{sku: sku} = product, quantity) when not is_nil(sku) do
    cart_item  = struct %CartItem{}, product
    %{cart_item | quantity: quantity}
  end

end

# def handle_call({:select_item, item, _quantity}, _sender, order) when item == nil do
#   order = %{order | message: "That item doesn't exist in our catalog"}
#   {:reply, order, order}
# end
#
# def handle_call({:select_item, item, quantity}, _sender, order) when item != nil do
#   cart_item  = struct %CartItem{}, item
#   cart_item = %{cart_item | quantity: quantity}
#
#   order = order
#           |> SalesOrder.locate_item(cart_item)
#           |> SalesOrder.add_item
#           |> save_change
#
#   {:reply, order, order}
#
# end
