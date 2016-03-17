defmodule Peach.Store do
  use Application
  import Plug.Conn

  import Supervisor.Spec, warn: false

  def init([]) do

  end

  def call(conn, _opts \\ []) do
    conn = conn |> fetch_cookies
    key = conn.cookies["order_key"] || UUID.uuid4()
    conn
      |> put_resp_cookie("order_key", key, http_only: true, max_age: 60 * 60 * 24 * 14)
      |> Peach.Sales.current
  end

  #app stuff
  def start(_type, _args) do
    start_moebius
    start_catalog
    start_order_supervisor
    start_order_processor
  end

  def start_moebius do
    #TODO: Pull this from App env
    db_worker = worker(Peach.Db.Postgres, [Moebius.get_connection])
    Supervisor.start_link [db_worker], strategy: :one_for_one

  end

  def start_order_supervisor do
    #spec the session supervisor
    worker = worker(Peach.Sales, [])
    Supervisor.start_link([worker], strategy: :simple_one_for_one, name: Peach.SalesSupervisor)
  end

  def start_order_processor do
    worker = worker(Peach.Fulfillment, [])
    Supervisor.start_link([worker], strategy: :simple_one_for_one, name: Peach.FulfillmentSupervisor)
  end

  def start_catalog do
    #start the supervised Catalog - one per domain
    catalog_worker = worker(Peach.Sales.Catalog, [])
    Supervisor.start_link [catalog_worker], strategy: :one_for_one
  end

  def start_order(key: key) do
    Supervisor.start_child(Peach.SalesSupervisor, [%{key: key}])
  end

  def fulfill_order(%Peach.Accounting.SalesOrder{status: "payment-received"} = order) do
    Supervisor.start_child(Peach.FulfillmentSupervisor, [order])
  end

end
