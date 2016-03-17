defmodule Shoe do
  use Moebius.Database
end
defmodule Peach.CatalogTest do
  use ExUnit.Case
  alias Peach.Sales.Catalog

  test "the catalog returns all products" do
    products = Catalog.products
    assert length(products) == 10
  end

  test "catalog returns product by collection" do
    products = Catalog.collection slug: "gift-ideas"
    assert length(products) == 4
  end

  test "catalog returns product by sku" do
    product = Catalog.product sku: "johnny-liftoff"
    assert product.sku == "johnny-liftoff"
  end
end
