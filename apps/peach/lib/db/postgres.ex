defmodule Peach.Db.Postgres do
  use Moebius.Database
  import Moebius.DocumentQuery
  alias Peach.Accounting.SalesOrder
  alias Peach.Db.Postgres, as: Db

  #order stuff
  def find_or_create_order(%{key: key} = args) do
    res = case db(:orders) |> contains(key: key) |> Db.first do
      nil -> db(:orders) |> Db.save(struct(%SalesOrder{}, args))
      found -> %{found | items: reset_to_cart_items(found)}
    end
  end

  def save_transaction_details(order, invoice: invoice, transaction: trans) do
    transaction fn(tx) ->
      db(:transactions) |> Db.save(trans, tx)
      db(:invoices) |> Db.save(invoice, tx)
      db(:orders) |>  Db.save(order, tx)
    end
  end
  def save_order(order) do
    db(:orders) |>  Db.save(order)
  end

  def remove_order(order) do
    db(:orders) |> delete(order.id) |> Db.first
  end

  def get_mailer(key: key) do
    mailer = db(:mailers) |> contains(key: key) |> Db.first
    struct %Peach.Mailer{}, mailer
  end

  #catalog
  def products() do
    db(:products) |> contains(status: "published") |> Db.run
  end

  def collections() do
    db(:collections) |> Db.run
  end

  defp reset_to_cart_items(order) do
    for item <- order.items, do: struct(%Peach.Sales.CartItem{}, item)
  end

  #sales
  def record_transaction(tx) do
    db(:transactions) |> Db.save(tx)
  end

  def get_transaction(key: key) do
    db(:transactions) |> contains(key: key) |> Db.first
  end

end
