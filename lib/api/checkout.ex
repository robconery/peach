defmodule Peach.Router.Checkout do
  use Maru.Router
  plug Plug.Logger

  alias Peach.Sales

  version "v1"

  namespace :checkout do

    params do
      requires :token, type: String
      requires :customer_email, type: String
      optional :customer_name, type: String
    end

    post do
      case charge_customer(conn, params) do
        %{assigns: %{order: %{status: "closed"}}} = conn -> json(conn, %{success: true, message: "Charge Successful"})
        %{assigns: %{message: err}} = conn -> json(conn, %{success: false, message: err})
      end
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
