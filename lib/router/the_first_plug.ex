defmodule TheFirstPlug do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    # IO.puts(conn.request_path)
    put_resp_content_type(conn, "application/json")
    # if conn.request_path === "/", do: send_resp(conn, 200, "Welcome to the new world of Plugs!")
    # if(conn.request_path === "/hello/", do: send_resp(conn, 200, "hello!"))
    case conn.request_path do
      "/" ->
        send_resp(conn, 200, "Welcome to the new world of Plugs!")

      "/me/" ->
        send_resp(
          conn,
          200,
          "I am The First, The One, Le Geant Plug Vert, Le Grand Plug, Le Plug Cosmique."
        )

      _ ->
        send_resp(conn, 404, "Go away, you are not welcome here.")
    end
  end
end
