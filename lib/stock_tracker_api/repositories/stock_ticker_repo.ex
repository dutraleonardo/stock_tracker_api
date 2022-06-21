defmodule StockTrackerApi.StockTickerRepo do
  @moduledoc false

  alias StockTrackerApi.QuoteRepo
  alias StockTrackerApi.Repo
  alias StockTrackerApi.StockTicker

  require Logger

  def insert(data) do
    data
    |> StockTicker.changeset()
    |> Repo.insert()
  end

  def full_insert(data) do
    Logger.info("FULL INSERT #{inspect(data)}")

    Repo.transaction(fn ->
      stock_ticker_id = get_or_insert(data.symbol)

      # Build quote from the stock_ticker struct
      {:ok, insert_quote} =
        data
        |> Map.put(:stock_ticker_id, stock_ticker_id)
        |> QuoteRepo.insert()

      insert_quote
    end)
  end

  def get_or_insert(symbol) do
    case get_by_symbol(symbol) do
      nil ->
        {:ok, %{id: id}} =
          %{symbol: symbol}
          |> insert()

        id

      %{id: id} ->
        id
    end
  end

  def get_by_symbol(symbol) do
    StockTicker
    |> Repo.get_by(symbol: symbol)
    |> Repo.preload(:quotes)
  end
end
