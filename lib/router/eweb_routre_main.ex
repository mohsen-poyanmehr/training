# defmodule MyJSONApi do
#   use Ewebmachine.Builder.Handlers
#   plug(:cors)
#   plug(:add_handlers, init: %{})

#   content_types_provided(do: ["application/json": :to_json])
#   defh(to_json, do: Poison.encode!(state[:json_obj]))

#   defp cors(conn, _), do: put_resp_header(conn, "Access-Control-Allow-Origin", "*")
# end

defmodule ErrorRoutesMain do
  use Ewebmachine.Builder.Resources
  resources_plugs

  resource "/error/:status" do
    %{s: elem(Integer.parse(status), 0)}
  after
    content_types_provided(do: ["text/html": :to_html, "application/json": :to_json])
    defh(to_html, do: "<h1> Error ! : '#{Ewebmachine.Core.Utils.http_label(state.s)}'</h1>")

    defh(to_json,
      do: ~s/{"error": #{state.s}, "label": "#{Ewebmachine.Core.Utils.http_label(state.s)}"}/
    )

    finish_request(do: {:halt, state.s})
  end
end

defmodule EwebRouterMain do
  require Server.Database
  use Ewebmachine.Builder.Resources
  if Mix.env() == :dev, do: plug(Ewebmachine.Plug.Debug)
  resources_plugs(error_forwarding: "/error/:status", nomatch_404: true)
  plug(ErrorRoutesMain)

  # plug(:resource_match)
  # plug(Ewebmachine.Plug.Run)
  # plug(Ewebmachine.Plug.Send)

  resource("/search/") do
    conn = fetch_query_params(conn)
    %{"id" => id} = conn.params
    foundInFormatList = Server.Database.searchTable(Server.Database, [id])
    elementInsideFoundInFormatListIsMap = Enum.at(foundInFormatList, 0)
    secondElementIsMap = elem(elementInsideFoundInFormatListIsMap, 1)
    order_id = secondElementIsMap["id"]
    %{order_id: order_id}
  after
    content_types_provided(do: ["text/html": :to_html])
    defh(to_html, do: "<html><h1>found #{state.order_id}</h1></html>")
  end

  resource("/update/") do
    conn = fetch_query_params(conn)
    %{"id" => id, "key" => key, "value" => value} = conn.params
    updated_order = Server.Database.update(Server.Database, {id, key, value})
    elementInsideUpdated_order = Enum.at(updated_order, 0)
    secondElementIsMap = elem(elementInsideUpdated_order, 1)
    type = secondElementIsMap["type"]
    %{type: type}
  after
    content_types_provided(do: ["text/html": :to_html])
    defh(to_html, do: "<html><h1>found #{state.type}</h1></html>")
  end

  resource("/delete/") do
    conn = fetch_query_params(conn)
    %{"id" => id} = conn.params
    foundInFormatList = Server.Database.searchTable(Server.Database, [id])

    if foundInFormatList !== [] do
      Server.Database.delete(Server.Database, id)
      %{alert: id}
    else
      %{alert: "not found"}
    end
  after
    content_types_provided(do: ["text/html": :to_html])
    defh(to_html, do: "<html><h1>element deletet #{state.alert}</h1></html>")
  end
end
