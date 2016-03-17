defmodule Peach.Sales.Catalog do
  use GenServer
  import Moebius.DocumentQuery
  alias Peach.Db.Postgres, as: Db

  @name __MODULE__

  #standard entry point
  def start_link do
    GenServer.start_link(__MODULE__,[], name: @name)
  end

  def init([]) do
    #load the products into the session
    products = Db.products()
    collections = Db.collections()
    {:ok, %{products: products, collections: collections}}
  end

  #public api
  def products() do
    GenServer.call(@name, {:products})
  end

  def collection(slug: slug) do
    GenServer.call(@name, {:products_by_collection, slug: slug})
  end

  def collections do
    GenServer.call(@name, {:collections})
  end

  def product(sku: sku) do
    GenServer.call(@name, {:sku, sku})
  end

  def products(collection: slug) do
    GenServer.call(@name, {:products_by_collection, slug: slug})
  end

  #GenServer hooks

  def handle_call({:products}, _sender, %{products: products} = state) do
    {:reply, products, state}
  end

  def handle_call({:collections}, _sender, %{collections: collections} = state) do
    {:reply, collections, state}
  end

  def handle_call({:products_by_collection, slug: slug}, _sender, %{products: products} = state) do
    result = for p <- products, Enum.any?(p.collections, &(&1 == slug)), do: p
    {:reply, result, state}
  end

  def handle_call({:sku, sku}, _sender, %{products: products} = state) do
    result = Enum.find products, nil, &(&1.sku == sku)
    {:reply, result, state}
  end

end
