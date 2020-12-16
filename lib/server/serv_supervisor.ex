defmodule Server.Supervisor do
  use Supervisor
  require Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Server.Database, name: Server.Database},
      Plug.Adapters.Cowboy.child_spec(:http, MyRouter, [], port: 8080),
      Plug.Adapters.Cowboy.child_spec(:http, FSMROUTER, [], port: 9090),
      {DynamicSupervisor, strategy: :one_for_one, name: MyDynamicSupervisor}
    ]

    Logger.info("Starting SUPERVISOR...")
    Supervisor.init(children, strategy: :one_for_one)
  end
end
