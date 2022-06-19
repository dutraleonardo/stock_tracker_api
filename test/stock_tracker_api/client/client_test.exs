defmodule StockTrackerApi.ClientTest do
  use ExUnit.Case

  import Mox

  setup :verify_on_exit!

  @stock_ticker "TSLA"
  @host Application.get_env(:stock_tracker_api, __MODULE__, :host)
  @resp %{change: "10.9800", change_percent: "1.7175%", high: "662.9082", latest_trading_day: "2022-06-17", low: "639.5900", open: "640.3000", previous_close: "639.3000", price: "650.2800", symbol: "TSLA", volume: "30880590"}

  describe "global_quote/1" do
    test "it should get the current quote by stock ticker" do
      ApiClientBehaviourMock
      |> expect(:global_quote, fn _symbol ->
        {:ok, @resp}
      end)
      result = StockTrackerApi.Client.global_quote(@stock_ticker)
    end
  end
end
