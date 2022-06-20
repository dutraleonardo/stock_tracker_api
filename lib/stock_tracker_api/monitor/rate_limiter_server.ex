defmodule StockTrackerApi.Monitor.RateLimiterServer do
  use GenServer

  alias StockTrackerApi.Monitor

  require Logger

  @minute_limit Monitor.get_requests_minute_limit()
  @daily_limit Monitor.get_requests_daily_limit()
  @restore_after_minute Monitor.get_requests_timeframe()
  @restore_after_day 24 * 60 * 60 * 1000
  @table_key "limiter"
  @tables %{minute: :minute_counter, daily: :daily_counter}

  def start_link(_default) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def status() do
    case lookup() do
      {minutes, daily} when minutes + 1 > @minute_limit or daily + 1 > @daily_limit ->
        {:error, :rate_limited}
      _count ->
        :ok
    end
  end

  def init(_) do
    :ets.new(@tables.minute, [:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
    :ets.new(@tables.daily, [:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
    schedule_restore()
    {:ok, %{}}
  end

  def handle_info(:restore_minute, state) do
    Logger.info("Restoring minute request limits")
    :ets.delete_all_objects(@tables.minute)
    schedule_restore()
    {:noreply, state}
  end

  def handle_info(:restore_daily, state) do
    Logger.info("Restoring daily request limits")
    :ets.delete_all_objects(@tables.daily)
    schedule_restore()
    {:noreply, state}
  end

  def update_counter() do
    :ets.update_counter(@tables.minute, @table_key, {2, 1}, {@table_key, 0})
    :ets.update_counter(@tables.daily, @table_key, {2, 1}, {@table_key, 0})
  end

  def lookup() do
    case :ets.lookup(@tables.daily, @table_key) do
      [] ->
        {0, 0}
      _ ->
        minutes = :ets.lookup_element(@tables.minute, @table_key, 2)
        daily = :ets.lookup_element(@tables.daily, @table_key, 2)
        {minutes, daily}
    end
  end

  defp schedule_restore() do
    Process.send_after(self(), :restore_minute, @restore_after_minute)
    Process.send_after(self(), :restore_daily, @restore_after_day)
  end
end
