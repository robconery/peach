defmodule Peach.Fulfillment.Delivery do

  def prepare(%{sku: sku} = item) do
    #get the product - the Catalog is in memory so this shouldn't be N+1
    product = Peach.Sales.Catalog.product sku: item.sku
  end

  #A pattern-match for vimeo deliveries
  def set_delivery(%{delivery: %{type: :download, provider: "vimeo"}} = delivery) do
    delivery
  end

end
