defmodule Server.MyGenericServer do
  def loop({callback_module, server_state}) do
    receive do
      {:cast, request} ->
        loop({callback_module, callback_module.handle_cast(request, server_state)})

      {:call, request, pid} ->
        {response, server_state} = callback_module.handle_call(request, server_state)
        send(pid, response)
        loop({callback_module, server_state})
    end
  end

  def start_link(callback_module, server_initial_state) do
    {:ok, spawn_link(fn -> loop({callback_module, server_initial_state}) end)}
  end

  def cast(process_pid, request) do
    send(process_pid, {:cast, request})
    :ok
  end

  def call(process_pid, request) do
    send(process_pid, {:call, request, self()})

    receive do
      response -> response
    end
  end
end
