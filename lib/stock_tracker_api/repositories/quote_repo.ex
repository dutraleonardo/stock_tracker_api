defmodule StockTrackerApi.QuoteRepo do
  @moduledoc false

  alias StockTrackerApi.Quote
  alias StockTrackerApi.Repo

  def insert(quote_data) do
    quote_data
    |> fields_parser()
    |> Quote.changeset()
    |> Repo.insert()
  end

  def get_by_id(id) do
    Quote
    |> Repo.get(id)
  end

  def fields_parser(data) do
    %{
      change: str_to_float(data.change),
      change_percent: str_to_float(data.change_percent),
      high: str_to_float(data.high),
      latest_trading_day: Date.from_iso8601!(data.latest_trading_day),
      low: str_to_float(data.low),
      open: str_to_float(data.open),
      previous_close: str_to_float(data.previous_close),
      price: str_to_float(data.price),
      volume: String.to_integer(data.volume),
      stock_ticker_id: data.stock_ticker_id
    }
  end

  defp str_to_float(value) do
    value
    |> Float.parse()
    |> elem(0)
  end
end
