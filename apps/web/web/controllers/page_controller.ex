defmodule Redfour.Web.PageController do
  use Redfour.Web.Web, :controller

  def index(conn, _params) do
    products = Peach.Sales.Catalog.collection slug: "featured"
    render conn, "index.html", featured: products
  end
end
