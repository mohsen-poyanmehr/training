defmodule JsonLoader do
  require Server.Database

  def load_to_database(database, filename) do
    with {:ok, file_content} <- File.read(filename) do
      mapJson = Poison.decode!(file_content)

      Enum.each(mapJson, fn element ->
        :ets.insert(
          database,
          {element["id"], element}
        )
      end)
    end
  end

  def initialize_orders(database) do
    Server.Database.get_orders(database)
    |> Enum.map(fn {id, order} ->
      updatedMapState = Map.put(order["status"], "state", "init")
      updatedMapComplete = Map.put(order, "status", updatedMapState)
      :ets.insert(database, {id, updatedMapComplete})
    end)
  end
end
