defmodule StockTrackerApiWeb.StockTickerView do
  use StockTrackerApiWeb, :view

  def render("quote.json", %{stock_ticker: stock_quote}) do
    %{
      symbol: stock_quote.stock_ticker.symbol,
      change: stock_quote.change,
      change_percent: stock_quote.change_percent,
      high: stock_quote.high,
      latest_trading_day: stock_quote.latest_trading_day,
      low: stock_quote.low,
      open: stock_quote.open,
      previous_close: stock_quote.previous_close,
      price: stock_quote.price,
      volume: stock_quote.volume
    }
  end

  def render("quotes.json", %{quotes: stock_quote}) do
    render_many(stock_quote, __MODULE__, "quote.json")
  end
end
