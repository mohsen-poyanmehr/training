defmodule FSMROUTER do
  require Server.Database
  require FSM.SERVER
  use Plug.Router

  @id "id"

  plug(:match)
  plug(:dispatch)

  # get "/run/" do
  #   # populates conn.params
  #   conn = fetch_query_params(conn)
  #   %{@id => id} = conn.params

  #   # foundInFormatList = Server.Database.searchTable(Server.Database, [id])
  #   # elementInsideFoundInFormatListIsMap = Enum.at(foundInFormatList, 0)
  #   # secondElementIsMap = elem(elementInsideFoundInFormatListIsMap, 1)
  #   # order = secondElementIsMap

  #   # {:ok, pid} = FSM.SERVER.run(order)
  #   send_resp(conn, 200, "run order with id #{conn.params["id"]} in #{Server.Database}")
  # end

  get "/search/" do
    # populates conn.params
    conn = fetch_query_params(conn)
    %{@id => id} = conn.params

    found = Server.Database.searchTable(Server.Database, [id])

    case found do
      [] ->
        send_resp(conn, 400, "element does not exist")

      _ ->
        send_resp(
          conn,
          200,
          "found #{elem(Enum.at(found, 0), 0)} in #{Server.Database} with  parametre #{
            conn.params["id"]
          }"
        )
    end
  end

  get "/update/" do
    # populates conn.params
    conn = fetch_query_params(conn)
    %{@id => id} = conn.params

    foundInFormatList = Server.Database.searchTable(Server.Database, [id])
    elementInsideFoundInFormatListIsMap = Enum.at(foundInFormatList, 0)
    secondElementIsMap = elem(elementInsideFoundInFormatListIsMap, 1)
    order = secondElementIsMap
    {:ok, pid} = FSM.SERVER.run(order)
    new_order = FSM.SERVER.transaction(pid, pid)

    new_order_json = Poison.encode!(new_order)

    send_resp(
      conn,
      200,
      """
      updated order with #{conn.params["id"]} in #{Server.Database}
      to #{new_order_json}
      ..........
      """
    )
  end
end
