defmodule StockTrackerApi.Client do
  @moduledoc """
  A client to get data from Alpha Vantage API.
  """

  @doc """
  Uses Alpha Vantage's `GLOBAL_QUOTE` function.
  Returns the latest price and volume information for a given security.
  Args:
  * `symbol` - The symbol of the security to use. E.g. `TSLA`
  ## Examples:
      iex> StockTrackerApi.Client.call(:global_quote, "TSLA")
      {:ok,
        %{
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
      }
  """

  def call(:global_quote, symbol), do: client_impl().global_quote(symbol)

  def call(function, _), do: {:error, "Function :#{function} not implemented yet."}

  defp client_impl, do: Application.get_env(:stock_tracker_api, :client_impl)
end
