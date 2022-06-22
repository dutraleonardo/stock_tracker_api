defmodule StockTrackerApi.QuoteRepo do
  @moduledoc false

  import Ecto.Query
  alias StockTrackerApi.Quote
  alias StockTrackerApi.Repo
  alias StockTrackerApi.StockTicker

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

  defp base_query do
    from(q in Quote)
  end

  defp end_filter(query, end_date) do
    query
    |> where([q], q.latest_trading_day <= ^end_date)
  end

  defp start_filter(query, start_date) do
    query
    |> where([q], q.latest_trading_day >= ^start_date)
  end

  defp volume_filter(query, min_volume) do
    query
    |> where([q], q.volume > ^min_volume)
  end

  defp stock_ticker_filter(query, symbol) do
    query
    |> join(:inner, [q], st in StockTicker, on: q.stock_ticker_id == st.id)
    |> where([q, st], st.symbol == ^symbol)
  end

  def filter(filters) do
    base_query()
    |> build_query(filters)
    |> Repo.all()
    |> Repo.preload(:stock_ticker)
  end

  defp build_query(queryable, filters),
    do: Enum.reduce(filters, queryable, &apply_filter/2)

  def apply_filter(clause, query) do
    case clause do
      {"start", start_date} ->
        start_date = Date.from_iso8601!(start_date)
        start_filter(query, start_date)

      {"end", end_date} ->
        end_date = Date.from_iso8601!(end_date)
        end_filter(query, end_date)

      {"stock_ticker", symbol} ->
        stock_ticker_filter(query, symbol)

      {"min_volume", min_volume} ->
        volume_filter(query, String.to_integer(min_volume))
    end
  end
end
