defmodule Redfour.Web.CartController do
  use Redfour.Web.Web, :controller
  alias Peach.Sales
  alias Peach.Shopping.Order

  def show(conn, _params) do
    render conn, "show.html"
  end

  def add_item(conn, params) do
    sku = params["product"]["sku"]
    quantity = params["product"]["quantity"] || 1
    conn
      |> Sales.select_item(sku: sku, quantity: quantity)
      |> redirect(to: cart_path(conn, :show))
  end

  def payment(conn, _params) do
    render conn, "checkout.html"
  end

end
