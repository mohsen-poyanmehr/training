defmodule Router do
  # orders = [
  #   %{"id" => "toto", "key" => 42},
  #   %{"id" => "test", "key" => "42"},
  #   %{"id" => "tata", "key" => "Apero?"},
  #   %{"id" => "kbrw", "key" => "Oh yeah"}
  # ]

  # {:ok, _my_supervisor} = Server.Supervisor.start_link([])
  # Server.Database.create(Server.Database, "ali")
  # JsonLoader.load_to_database(
  #   Server.Database,
  #   "/home/mohsen/router/orders_dump/orders_chunk0.json"
  # )

  # orders_filter = Server.Database.search(orders, [{"key", 42}, {"key", "42"}, {"key", "Oh yeah"}])
  # IO.inspect(orders_filter)
  require Server.AccountServer
  require Server.MyGenericServer

  {:ok, my_account} = Server.AccountServer.start_link(5)
  Server.MyGenericServer.cast(my_account, {:credit, 5})
  Server.MyGenericServer.cast(my_account, {:credit, 2})
  Server.MyGenericServer.cast(my_account, {:debit, 3})
  amount = Server.MyGenericServer.call(my_account, :get)
  IO.puts("current credit hold is #{amount}")
end
