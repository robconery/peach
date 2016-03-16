defmodule Peach.Sales do
  use GenServer
  import Peach.Util
  alias Peach.Sales.CartItem
  alias Peach.Db.Postgres, as: Db
  alias Peach.Accounting.SalesOrder
  import Plug.Conn

  def start_link(%{key: key}) when is_atom(key), do: start_link(%{key: Atom.to_string(key)})
  def start_link(%{key: key} = args) when is_binary(key) do
    order = Db.find_or_create_order(args)
    Agent.start_link fn -> order end, name: get_name(key)
  end

  def current(%Plug.Conn{cookies: %{"order_key" => key}} = conn) do
    unless exists?(key), do: Peach.Store.start_order key: key
    order = Agent.get(get_name(key), &(&1))
    assign conn, :order, order
  end

  def select_item(_pid, sku: sku) when (sku == nil),
      do: {:error, "A sku is required"}

  def select_item(_pid, sku: _sku, quantity: quantity) when quantity <=0,
      do: {:error, "Adding 0 (or fewer) items to the cart is not supported. Please use remove_item or change_item"}

  def select_item(%Plug.Conn{cookies: %{"order_key" => key}} = conn, sku: sku, quantity: quantity)
    when (sku != nil) and quantity > 0 do
      product = Peach.Sales.Catalog.product sku: sku
      order = conn.assigns.order

      order = case CartItem.create_from_product product, quantity do
        nil -> %{order | message: "That item doesn't exist in our catalog"}
        cart_item ->  order |> SalesOrder.locate_item(cart_item) |> SalesOrder.add_item |> save_change
      end
      assign conn, :order, order
  end

  def change_item(%Plug.Conn{cookies: %{"order_key" => key}} = conn, sku: sku, quantity: quantity) when quantity > 0 do
    order = conn.assigns.order
              |> SalesOrder.locate_item(%{sku: sku})
              |> SalesOrder.change_quantity(quantity: quantity)
              |> save_change

    assign conn, :order, order
  end

  def change_item(%Plug.Conn{} = conn, sku: sku, quantity: quantity) when quantity <= 0,
    do: remove_item(conn, sku: sku)

  def change_item(_pid, sku: sku) when sku ==nil, do: {:error, "A sku is required"}

  def remove_item(%Plug.Conn{cookies: %{"order_key" => key}} = conn, sku: sku) when sku !=nil do
    order = conn.assigns.order
              |> SalesOrder.locate_item(%{sku: sku})
              |> SalesOrder.remove_item
              |> save_change
    assign conn, :order, order
  end

  def remove_item(_pid, sku: sku) when sku ==nil,
    do: {:error, "A sku is required"}


  def empty_items(%Plug.Conn{cookies: %{"order_key" => key}} = conn) do
    order = {:ok, order: %{conn.assigns.order | items: []}, log: "Cart emptied"} |> save_change
    assign conn, :order, order
  end


  def record_sale(%Plug.Conn{cookies: %{"order_key" => key}} = conn, payment: payment, processor: "stripe", response: response) do

    #TODO: This is losing it's structiness... why?
    order = conn.assigns.order

    invoice = Peach.Accounting.Invoice.create_from_stripe_response(order: order, payment: payment, response: response)
    payment_details = %{
      processor: "stripe",
      payment: payment,
      response: response
    }

    order = {:ok, order: %{order | invoice: invoice, payment: payment_details, status: "payment-received"}, log: "Recording sale"}
      |> save_change

    assign conn, :order, order
  end

  def close(%Plug.Conn{cookies: %{"order_key" => key}, assigns: %{order: %{status: "payment-received"}}} = conn) do

    #reset the cookie
    conn = put_resp_cookie(conn, "order_key", UUID.uuid4())

    #set the status to closed
    final = {:ok, order: %{conn.assigns.order | status: "closed"}, log: "Closing order"} |> save_change

    #stop the Agent
    Agent.stop(get_name(key), :normal)

    #empty the order
    assign conn, :order, final
  end


  ############################ Privvies
  defp get_name(key) when is_binary(key), do: {:global, {:order, key}}
  defp get_name(%Plug.Conn{cookies: %{"order_key" => key}}), do: get_name(key)

  defp exists?(key) when is_binary(key) do
    :global.whereis_name({:order_key, key}) != :undefined
  end

  defp save_change({:error, order: order, message: mssg}), do: %{order | message: mssg}
  defp save_change({:ok, order: order, log: log}) do
    #pull the agent and reset state, saving in the DB as well
    Agent.get_and_update get_name(order.key), fn _order ->
      saved = %{order | summary: SalesOrder.summarize(order)}
        |> SalesOrder.add_log_entry(log)
        |> Db.save_order
      {saved, saved}
    end
  end

end
