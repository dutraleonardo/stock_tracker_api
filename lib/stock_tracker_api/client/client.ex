defmodule StockTrackerApi.Client do

  @doc """
  Uses Alpha Vantage's `GLOBAL_QUOTE` function.
  Returns the latest price and volume information for a given security.
  Args:
  * `symbol` - The symbol of the security to use. E.g. `TSLA`
  ## Examples:
      iex> StockTrackerApi.Client.call(:global_quote, "TSLA")
      %{
        "Global Quote" => %{
            "01. symbol" => "TSLA",
            "02. open" => "640.3000",
            "03. high" => "662.9082",
            "04. low" => "639.5900",
            "05. price" => "650.2800",
            "06. volume" => "30547170",
            "07. latest trading day" => "2022-06-17",
            "08. previous close" => "639.3000",
            "09. change" => "10.9800",
            "10. change percent" => "1.7175%"
        }
      }
  """

  def call(:global_quote, symbol), do: client_impl().global_quote(symbol)

  def call(function, _), do: {:error, "Function :#{function} not implemented yet."}

  defp client_impl, do: Application.get_env(:stock_tracker_api, :client_impl)
end
