defmodule StockTrackerApi.MonitorServer do
  @moduledoc """
  Responsible of handling my job's schedule.

  * Runs job on start and every tem thereafter.
  """
  use GenServer

  alias StockTrackerApi.Client
  alias StockTrackerApi.Monitor.RateLimiterServer
  alias StockTrackerApi.StockTickerRepo

  require Logger

  @job_timeframe Application.compile_env!(:stock_tracker_api, __MODULE__) |> Keyword.get(:job_timeframe)

  def start_link(_default) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    state = %{
      function: nil,
      symbol: nil
    }

    {:ok, state}
  end

  def make_request(function, symbol) do
    GenServer.cast(__MODULE__, {:request, {function, symbol}})
  end

  def handle_cast({:request, {function, symbol}}, state) do
    async_request(function, symbol)
    schedule_next_job(function, symbol)
    {:noreply, %{state | function: function, symbol: symbol}}
  end

  def handle_info({:request, {function, symbol}}, state) do
    async_request(function, symbol)
    schedule_next_job(function, symbol)
    {:noreply, state}
  end

  def handle_info({ref, _result}, state) do
    Process.demonitor(ref, [:flush])

    {:noreply, state}
  end

  # If the task fails...
  def handle_info({:DOWN, _ref, _, _, reason}, state) do
    Logger.info("Stock ticker #{inspect(state.symbol)} failed with reason #{inspect(reason)}")
    {:noreply, state}
  end

  defp async_request(function, symbol) do
    case RateLimiterServer.available?() do
      :ok ->
        Task.Supervisor.async_nolink(MonitorServer.TaskSupervisor, fn ->
          {:ok, data} = Client.call(function, symbol)
          StockTickerRepo.full_insert(data)
        end)

      {:error, reason} ->
        Logger.info("Failed to process #{symbol}, error caused by #{reason}")
    end
  end

  defp schedule_next_job(function, symbol) do
    Logger.info("Schedule: The next run of #{symbol} will take place in #{@job_timeframe / 1000} seconds")
    Process.send_after(self(), {:request, {function, symbol}}, @job_timeframe)
  end
end
