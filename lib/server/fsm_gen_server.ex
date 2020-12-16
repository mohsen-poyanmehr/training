defmodule FSM.SERVER do
  @timeout 10000

  require Server.Database
  require Logger
  use GenServer

  def run(order) do
    child_spec = {FSM.SERVER, order["id"]}
    DynamicSupervisor.start_child(MyDynamicSupervisor, child_spec)
  end

  def isAlive(pid) do
    Process.alive?(pid)
  end

  def start_link(id) do
    foundInFormatList = Server.Database.searchTable(Server.Database, [id])
    elementInsideFoundInFormatListIsMap = Enum.at(foundInFormatList, 0)
    secondElementIsMap = elem(elementInsideFoundInFormatListIsMap, 1)
    order = secondElementIsMap
    # state = secondElementIsMap["status"]["state"]
    GenServer.start_link(__MODULE__, order, [])
  end

  def transaction(server, pid) do
    case isAlive(pid) do
      true ->
        reply = GenServer.call(server, {:transaction, pid})

        stop(server)
        reply

      _ ->
        "#{inspect(pid)} is not exist"
    end
  end

  def stop(server) do
    GenServer.stop(server, :normal)
  end

  @impl true
  def init(order) do
    Logger.info("starting up with timeout #{@timeout}")
    {:ok, order, @timeout}
  end

  @impl true
  def handle_call({:transaction, _pid}, _from, order) do
    result_process_payment = ExFSM.Machine.event(order, {:process_payment, []})

    if elem(result_process_payment, 0) === :next_state do
      result_verfication =
        ExFSM.Machine.event(elem(elem(result_process_payment, 1), 1), {:verfication, []})

      :ets.insert(
        Server.Database,
        {elem(elem(result_process_payment, 1), 1)["id"], elem(elem(result_process_payment, 1), 1)}
      )

      if elem(result_verfication, 0) === :next_state do
        :ets.insert(
          Server.Database,
          {elem(elem(result_verfication, 1), 1)["id"], elem(elem(result_verfication, 1), 1)}
        )

        {:reply, elem(elem(result_verfication, 1), 1), elem(elem(result_verfication, 1), 1)}
      else
        {:reply, :action_unavailable, order}
      end
    else
      {:reply, :action_unavailable, order}
    end
  end

  # handle termination
  @impl true
  def terminate(reason, _order) do
    Logger.info("terminating")
    # IO.puts("#{__MODULE__}.terminate/2 called wit reason: #{inspect(reason)} #{inspect(order)}")
    IO.puts("#{__MODULE__}.terminate/2 called wit reason: #{inspect(reason)}")
    # order
  end
end
