defmodule StockTrackerApi.Monitor.RateLimiterServer do
  @moduledoc """
  This GenServer controls and guarantees that the application does not exceed the maximum limits of requests to the Alpha Vantage API.
  """
  use GenServer

  require Logger

  @minute_limit String.to_integer(
                  Application.compile_env!(:stock_tracker_api, __MODULE__)
                  |> Keyword.get(:minute_limit)
                )
  @daily_limit String.to_integer(Application.compile_env!(:stock_tracker_api, __MODULE__) |> Keyword.get(:daily_limit))
  @restore_after_minute Application.compile_env!(:stock_tracker_api, __MODULE__) |> Keyword.get(:requests_timeframe)
  @restore_after_day 24 * 60 * 60 * 1000
  @table_key "limiter"
  @tables %{minute: :minute_counter, daily: :daily_counter}

  def start_link(_default) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def available? do
    case lookup() do
      {minutes, daily} when minutes + 1 > @minute_limit or daily + 1 > @daily_limit ->
        {:error, :rate_limited}

      _count ->
        update_counter()
        {minute, daily} = lookup()
        Logger.info("RateLimiter: used #{minute} API requests from minute limite and #{daily} from day")
        :ok
    end
  end

  def init(_) do
    :ets.new(@tables.minute, [:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
    :ets.new(@tables.daily, [:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
    schedule_restore()
    {:ok, nil}
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

  defp update_counter do
    :ets.update_counter(@tables.minute, @table_key, {2, 1}, {@table_key, 0})
    :ets.update_counter(@tables.daily, @table_key, {2, 1}, {@table_key, 0})
  end

  def lookup_daily do
    case :ets.lookup(@tables.daily, @table_key) do
      [] ->
        {:ok, 0}

      _ ->
        {:ok, :ets.lookup_element(@tables.daily, @table_key, 2)}
    end
  end

  def lookup_minute do
    case :ets.lookup(@tables.minute, @table_key) do
      [] ->
        {:ok, 0}

      _ ->
        {:ok, :ets.lookup_element(@tables.minute, @table_key, 2)}
    end
  end

  def lookup do
    with {:ok, daily_used} <- lookup_daily(),
         {:ok, minute_used} <- lookup_minute() do
      {minute_used, daily_used}
    end
  end

  defp schedule_restore do
    Process.send_after(self(), :restore_minute, @restore_after_minute)
    Process.send_after(self(), :restore_daily, @restore_after_day)
  end

  def config(key), do: Application.get_env(:stock_tracker_api, __MODULE__) |> Keyword.get(key)
end
