defmodule StockTrackerApi.Monitor do
  alias StockTrackerApi.MonitorServer

  def handle_request(symbol) do
    MonitorServer.make_request(:global_quote, symbol)
  end

  def get_requests_minute_limit, do: String.to_integer(config(:minute_limit))
  def get_requests_daily_limit, do: String.to_integer(config(:daily_limit))
  def get_requests_timeframe, do: config(:requests_timeframe)
  def get_job_schedule_time, do: config(:job_timeframe)
  def retry_after(), do: floor(get_requests_timeframe() / get_requests_minute_limit())

  defp config(key), do: Application.get_env(:stock_tracker_api, __MODULE__) |> Keyword.get(key)
end
