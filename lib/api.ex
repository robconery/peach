defmodule Peach.API do
  use Maru.Router
  plug Plug.Logger
  plug Peach.Store

  mount Peach.Router.Catalog
  mount Peach.Router.Cart


  #TODO: Put a manifest here? Would make good sense and feel a bit
  #HATEOS YO
  get do
    manifest = %{
      all_products: "/v1/catalog",
      product_by_sku: "/v1/catalog/:sku",
      products_by_collection: "/v1/catalog/collections/:collection",
      collections: "/v1/catalog/collections/"
    }
    conn |> json(manifest)
  end

  rescue_from Unauthorized do
    status 401
    conn
      |> put_status(401)
      |> text("Unauthorized")
  end

  rescue_from Maru.Exceptions.NotFound, as: e do
    IO.inspect "404: URL Not Found at path /#{e.path_info}"
    conn |>
      put_status(404) |>
      text("This URL is invalid")
  end

  rescue_from Maru.Exceptions.MethodNotAllow do
    IO.inspect "405: Method Not allowed"
    conn
      |> put_status(405)
      |> text("Method Not Allowed")
  end

  rescue_from [MatchError, UndefinedFunctionError], as: e do
    e |> IO.inspect

    conn
      |> put_status(500)
      |> text "Run time error"
  end

end
