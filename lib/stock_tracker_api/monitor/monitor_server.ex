defmodule StockTrackerApi.MonitorServer do
  @moduledoc """
  Responsible of handling my job's schedule.

  * Runs job on start and every tem thereafter.
  """
  use GenServer

  alias StockTrackerApi.Client
  alias StockTrackerApi.Monitor
  alias StockTrackerApi.Monitor.RateLimiterServer

  require Logger

  @job_timeframe Monitor.get_job_schedule_time()
  @retry_after_fail Monitor.retry_after()

  def start_link(_default) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{tasks: %{}}}
  end

  def make_request(function, symbol) do
    GenServer.call(__MODULE__, {:request, {function, symbol}})

  end

  def handle_call({:request, {function, symbol}}, _from, state) do
    case RateLimiterServer.status() do
      :ok ->
        task =
            Task.Supervisor.async_nolink(MonitorServer.TaskSupervisor, fn ->
              RateLimiterServer.update_counter()
              Client.call(function, symbol)
            end)

        state = put_in(state.tasks[task.ref], symbol)

        schedule_next_job()
        {:reply, :ok, state}

      {:error, reason} ->
        Logger.info("Failed to process #{symbol}, error caused by #{reason}")
        schedule_failed_job()

    end

  end

  def handle_info({ref, {:ok, result}}, state) do
    # The task succeed so we can cancel the monitoring and discard the DOWN message
    Process.demonitor(ref, [:flush])

    {symbol, state} = pop_in(state.tasks[ref])
    Logger.info("Got #{inspect(result)} for stock ticker: #{inspect symbol}")
    {:noreply, result}
  end

  # If the task fails...
  def handle_info({:DOWN, ref, _, _, reason}, state) do
    {symbol, state} = pop_in(state.tasks[ref])
    Logger.info("Stock ticker #{inspect symbol} failed with reason #{inspect(reason)}")
    {:noreply, state}
  end

  defp schedule_failed_job() do
    Process.send_after(self(), :request, @retry_after_fail)
  end

  defp schedule_next_job() do
    Process.send_after(self(), :request, @job_timeframe)
  end
end
