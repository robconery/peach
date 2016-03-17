defmodule Peach.Router.Catalog do
  use Maru.Router
  plug Plug.Logger

  alias Peach.Sales.Catalog

  version "v1"

  namespace :catalog do

    get do: conn |> json Catalog.products

    namespace :collections do

      get do: conn |> json Catalog.collections
      get ":id", do: conn |> json Catalog.products(collection: params[:id])

    end

    get ":slug",  do: conn |> json Catalog.product(sku: params[:slug])

  end


end
