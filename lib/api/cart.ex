defmodule Peach.Router.Cart do
  use Maru.Router
  plug Plug.Logger

  alias Peach.Sales

  version "v1"
 
  namespace :cart do
    get do: conn |> json conn.assigns.order

    desc "Adding an item to the cart"
    params do
      group :product do
        requires :sku, type: String
        optional :quantity, type: Integer, default: 1
      end
    end

    #create
    post do
      conn
        |> Sales.select_item(sku: params[:sku], quantity: params[:quantity])
        |> json conn.assigns.order
    end

    #hopefully the quantity will come through the query string OK
    put ":sku" do
      conn
        |> Sales.change_item(sku: params[:sku], quantity: String.to_integer(params[:quantity]))
        |> json conn.assigns.order
    end

    delete ":sku" do
      conn
        |> Sales.remove_item(sku: params[:sku])
        |> json conn.assigns.order
    end
  end

end
