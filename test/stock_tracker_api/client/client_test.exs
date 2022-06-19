defmodule StockTrackerApi.ClientTest do
  use ExUnit.Case

  alias StockTrackerApi.Client

  import Mox

  setup :verify_on_exit!

  @stock_ticker "TSLA"
  @fail_functions [:intraday, :daily, :weekly, :monthly]
  @response %{
    change: "10.9800",
    change_percent: "1.7175%",
    high: "662.9082",
    latest_trading_day: "2022-06-17",
    low: "639.5900",
    open: "640.3000",
    previous_close: "639.3000",
    price: "650.2800",
    symbol: "TSLA",
    volume: "30880590"
  }

  describe "call/2" do
    test "it should get the current global quote by stock ticker for a valid stock ticker" do
      ClientApiBehaviourMock
      |> expect(:global_quote, fn _symbol ->
        {:ok, @response}
      end)

      {:ok, result} = Client.call(:global_quote, @stock_ticker)
      assert !is_nil(result.price)
      assert !is_nil(result.high)
      assert !is_nil(result.low)
      assert !is_nil(result.volume)
    end

    test "it should return an error that function not exists" do
      result =
        @fail_functions
        |> Enum.shuffle()
        |> hd
        |> Client.call("TSLA")

      assert elem(result, 0) == :error
      assert is_bitstring(elem(result, 1))
    end
  end
end
