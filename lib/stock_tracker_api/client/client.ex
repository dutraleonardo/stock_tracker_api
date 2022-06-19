defmodule StockTrackerApi.Client do
  @moduledoc """
  A client to get data from Alpha Vantage API.
  """

  use HTTPoison.Base

  alias StockTrackerApi.Client.Helper

  @behaviour StockTrackerApi.ClientBehaviour

  @doc """
  Uses Alpha Vantage's `GLOBAL_QUOTE` function.
  Returns the latest price and volume information for a given security.
  Args:
  * `symbol` - The symbol of the security to use. E.g. `TSLA`
  ## Examples:
      iex> StockTrackerApi.Client.global_quote("TSLA")
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

  def global_quote(symbol) do
    params = %{
      function: "GLOBAL_QUOTE",
      symbol: symbol,
      apikey: config(:api_key)
    }

    api_client().do_get(config(:host), params)
  end

  def api_client, do: Application.get_env(:stock_tracker_api, :api_client)

  defp do_get(url, params) do
    url
    |> get([], params: params)
    |> handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok,
         Jason.decode!(body)
         |> Helper.resolve_response()}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        if status >= 300 and status < 400, do: {:ok, body}, else: {:error, status}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp config(key), do: Application.get_env(:stock_tracker_api, __MODULE__) |> Keyword.get(key)
end
