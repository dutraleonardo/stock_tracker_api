defmodule StockTrackerApi.Client.Helper do
  @moduledoc false

  def resolve_response(response) do
    for {key, val} <- response["Global Quote"], into: %{}, do: {convert_key(key), val}
  end

  defp convert_key(key) do
    key
    |> String.split(" ", parts: 2)
    |> List.last()
    |> String.replace(" ", "_")
    |> String.to_atom()
  end
end
