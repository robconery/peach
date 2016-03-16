defmodule Redfour.Web.ApiV1Controller do

  use Redfour.Web.Web, :controller
  alias Peach.Sales

  def remove_cart_item(conn, %{"sku" => sku}) do

    conn = conn
      |> Sales.remove_item(sku: sku)

    json conn, conn.assigns.order
  end

  def update_cart_item(conn, %{"sku" => sku, "quantity" => quantity}) do

    conn = conn
      |> Sales.change_item(sku: sku, quantity: String.to_integer(quantity))

    json conn, conn.assigns.order
  end

  def execute_sale(conn, params) do

    case charge_customer(conn, params) do
      %{assigns: %{order: %{status: "closed"}}} = conn -> json(conn, %{success: true, message: "Charge Successful"})
      %{assigns: %{message: err}} = conn -> json(conn, %{success: false, message: err})
    end

  end

  defp charge_customer(conn, params) do

    payment = params["token"]
    order = conn.assigns.order

    #create the charge bits
    args = [
      source: payment["id"],
      capture: true,
      receipt_email: params["customer_email"]
    ]

    #talk to Stripe
    charge = Stripe.Charges.create(trunc(order.summary.total), args)

    #eval the response
    case charge do
      {:ok, response} -> conn |> Sales.record_sale(payment: params, processor: "stripe", response: response) |> Sales.close
      {:error, err} -> conn |> assign(:order, %{order | message: err})
    end
  end


end
