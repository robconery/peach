defmodule Redfour.Web.Router do
  use Redfour.Web.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Peach.Store
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Peach.Store
  end

  scope "/api/v1", Redfour.Web do
    pipe_through :api

    post "/cart/remove_item", ApiV1Controller, :remove_cart_item
    post "/cart/update_cart_item", ApiV1Controller, :update_cart_item
    post "/checkout", ApiV1Controller, :execute_sale
  end

  scope "/", Redfour.Web do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/catalog", Redfour.Web do
    pipe_through :browser

    get "/", CatalogController, :index
    get "/:sku", CatalogController, :show
  end


  scope "/cart", Redfour.Web do
    pipe_through :browser

    get "/", CartController, :show
    post "/", CartController, :add_item
    get "/checkout", CartController, :payment

  end




  # Other scopes may use custom stacks.
  # scope "/api", Redfour.Web do
  #   pipe_through :api
  # end
end
