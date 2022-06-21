defmodule StockTrackerApi.StockTickerRepoTest do
  use StockTrackerApi.DataCase, async: true

  alias StockTrackerApi.Client
  alias StockTrackerApi.StockTickerRepo

  import Mox

  setup :verify_on_exit!

  @stock_ticker "TSLA"
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

  setup do
    ClientApiBehaviourMock
    |> expect(:global_quote, fn _symbol ->
      {:ok, @response}
    end)

    {:ok, response} = Client.call(:global_quote, @stock_ticker)

    response
  end

  describe "insert/1" do
    test "successful insert symbol on stock_ticker table", data do
      {status, result} = StockTickerRepo.insert(data)
      assert status == :ok
      assert !is_nil(result.symbol)
    end

    test "raise changeset error", data do
      {status, result} =
        data
        |> Map.drop([:symbol])
        |> StockTickerRepo.insert()

      assert status == :error
      refute result |> Map.get(:valid?)
    end
  end

  describe "full_insert/1" do
    test "successful insert on stock_ticker and quote FK", data do
      {status, result} = StockTickerRepo.full_insert(data)

      assert status == :ok
      refute is_nil(result.stock_ticker_id)
      refute is_nil(result.volume)
      refute is_nil(result.high)
    end
  end

  describe "get_or_insert/1" do
    test "get stock ticker or create if not exist" do
      result = StockTickerRepo.get_or_insert(@stock_ticker)

      assert is_integer(result)
    end
  end
end
