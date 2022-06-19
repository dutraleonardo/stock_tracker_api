defmodule StockTrackerApi.Client.Api do
  @moduledoc false

  use HTTPoison.Base

  alias StockTrackerApi.Client.Helper

  @behaviour StockTrackerApi.Client.ApiBehaviour

  def global_quote(symbol) do
    params = %{
      function: "GLOBAL_QUOTE",
      symbol: symbol,
      apikey: config(:api_key)
    }

    config(:host)
    |> do_get(params)
  end

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
        if status >= 300 and status < 400, do: {:ok, body}, else: {:error, error_msg("status #{status}")}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "#{inspect(reason)}"}
    end
  end

  defp error_msg(cause), do: "An error has occurred caused by: #{cause}"

  defp config(key), do: Application.get_env(:stock_tracker_api, __MODULE__) |> Keyword.get(key)
end
