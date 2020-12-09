defmodule Router.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Starting application...")
    Supervisor.start_link(Server.Supervisor, :ok)
  end
end
