defmodule Server.Database do
  use GenServer
  # require FSM.SERVER
  ## Client API

  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  def create(server, {name, value}) do
    GenServer.cast(server, {:create, {name, value}})
  end

  def delete(server, name) do
    GenServer.cast(server, {:delete, name})
  end

  def update(server, {name, key, value}) do
    GenServer.call(server, {:update, {name, key, value}})
  end

  def lookup(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  ## Defining GenServer Callbacks

  @impl true
  def init(table) do
    IO.puts("create table: #{table} and fill it with file json")
    names = :ets.new(table, [:named_table, :set, :public])

    JsonLoader.load_to_database(
      Server.Database,
      "/home/mohsen/router/orders_dump/orders_chunk0.json"
    )

    IO.puts("initialize the state of #{table}")
    JsonLoader.initialize_orders(Server.Database)

    {:ok, {names, table}}
  end

  @impl true
  def handle_cast({:create, {name, value}}, {names, table}) do
    # Read and write to the ETS table
    case lookup(names, name) do
      {:ok, _pid} ->
        :ets.insert(names, {name, value})
        {:noreply, {names, table}}

      :error ->
        :ets.insert(names, {name, value})
        {:noreply, {names, table}}
    end
  end

  @impl true
  def handle_cast({:delete, name}, {names, table}) do
    # delete from ETS table
    case lookup(names, name) do
      {:ok, _pid} ->
        :ets.delete(names, name)
        {:noreply, {names, table}}

      :error ->
        IO.inspect("element doesn't exist to delete it")
        {:noreply, {names, table}}
    end
  end

  @impl true
  def handle_call({:update, {name, key, value}}, _from, {names, table}) do
    # update ETS table
    case lookup(names, name) do
      {:ok, _pid} ->
        foundInFormatList = searchTable(names, [name])
        elementInsideFoundInFormatListIsMap = Enum.at(foundInFormatList, 0)
        secondElementIsMap = elem(elementInsideFoundInFormatListIsMap, 1)
        updatedMap = Map.put(secondElementIsMap, key, value)
        :ets.insert(names, {name, updatedMap})
        updated = Server.Database.searchTable(names, [name])
        # IO.inspect(updated)
        {:reply, updated, {names, table}}

      :error ->
        IO.inspect("element doesn't exist to update it")
        {:reply, "no_change", {names, table}}
    end
  end

  def search(database, criteria) do
    Enum.flat_map(criteria, fn x ->
      Enum.filter(database, fn data ->
        data["key"] === elem(x, 1)
      end)
    end)
  end

  def searchTable(database, criteria) do
    Enum.flat_map(criteria, fn x ->
      :ets.lookup(database, x)
    end)
  end

  def get_orders(database) do
    :ets.tab2list(database)
  end
end
