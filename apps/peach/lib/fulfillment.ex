defmodule Peach.Fulfillment do
  alias Peach.Db.Postgres, as: Db
  import Plug.Conn
  import Peach.Util


  #this should be executed as a task
  def execute(%Peach.Accounting.SalesOrder{status: "payment-recieved"} = order) do
    order
      |> prepare_delivery
      |> provision
      |> send_order_confirmation_email
      |> send_order_fulfilled_email
  end

  def prepare_delivery(order) do
    deliverables = for item <- order.items, do: Peach.Fulfillment.Delivery.prepare item
    %{order | deliverables: deliverables}
  end

  defp fail(order, reason) do
    #log it, and set to "failed?"
  end

  defp provision(order) do
    order
  end

  defp prepare_mailers do
    #get the mailer bits from the DB
    order
  end

  defp send_order_confirmation_email(order) do
    order
  end

  defp send_order_fulfilled_email(order) do
    order
  end

  defp save_order({:error, order: order, message: mssg}), do: %{order | message: mssg}
  defp save_order({:ok, order: order, log: log}) do
    %{order | message: log, logs: List.insert_at(order.logs, -1, %{entry: log, date: now_iso})}
      |> Db.save_order
  end
end
