defmodule MyRouter do
  require Server.Database
  use Plug.Router

  @id "id"
  @value "type"

  plug(:match)
  plug(:dispatch)

  get "/search/" do
    # populates conn.params
    conn = fetch_query_params(conn)
    %{@id => id, @value => value} = conn.params

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
    %{@id => id, @value => value} = conn.params
    Server.Database.update(Server.Database, {id, @value, value})

    send_resp(
      conn,
      200,
      "updated #{conn.params["id"]} #{conn.params["type"]} in #{Server.Database}"
    )
  end

  get "/delete/" do
    # populates conn.params
    conn = fetch_query_params(conn)
    %{@id => id, @value => value} = conn.params
    Server.Database.delete(Server.Database, id)
    send_resp(conn, 200, "deleted #{conn.params["id"]} in #{Server.Database}")
  end

  match _ do
    send_resp(conn, 404, "Page Not Found")
  end
end
