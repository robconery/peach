defmodule Redfour.Web.CatalogController do
  use Redfour.Web.Web, :controller
  alias Peach.Shopping.Order

  def index(conn, _params) do
    products = Peach.Sales.Catalog.collection slug: "featured"
    render conn, "index.html", featured: products
  end

  def show(conn, _params) do
    sku = _params["sku"]
    #Session.browse conn, url: conn.request_path, sku: sku
    product = Peach.Sales.Catalog.product sku: sku
    render conn, "show.html", product: product
  end
end
