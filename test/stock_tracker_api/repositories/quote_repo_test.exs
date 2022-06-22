defmodule StockTrackerApi.QuoteRepoTest do
  use StockTrackerApi.DataCase, async: true

  alias StockTrackerApi.Client
  alias StockTrackerApi.QuoteRepo
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
    |> Map.put(:symbol, "GOOG")
    |> StockTickerRepo.full_insert()

    response
  end

  describe "insert/1" do
    test "successful insert stock quote", data do
      {:ok, %{id: stock_ticker_id}} = StockTickerRepo.insert(data)

      {status, result} =
        data
        |> Map.put(:stock_ticker_id, stock_ticker_id)
        |> QuoteRepo.insert()

      assert status == :ok
      assert is_integer(result.stock_ticker_id)
      refute is_nil(result.volume)
      refute is_nil(result.high)
    end
  end

  describe "filter/1" do
    test "apply filter by start and end date" do
      get_one = QuoteRepo.filter(%{"start" => "2022-06-17", "end" => "2022-06-18"})
      get_none = QuoteRepo.filter(%{"start" => "2022-06-18", "end" => "2022-06-20"})

      assert get_one != []
      assert get_none == []
    end

    test "apply filter by stock_ticker" do
      get_one = QuoteRepo.filter(%{"stock_ticker" => "GOOG"})
      get_none = QuoteRepo.filter(%{"stock_ticker" => @stock_ticker})

      assert get_one != []
      assert get_none == []
    end

    test "apply filter records above a min_volume" do
      get_one = QuoteRepo.filter(%{"min_volume" => "30880589"})
      get_none = QuoteRepo.filter(%{"min_volume" => "30880590"})

      assert get_one != []
      assert get_none == []
    end
  end
end
