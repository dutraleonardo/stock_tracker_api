defmodule StockTrackerApi.Client.ApiBehaviour do
  @moduledoc false
  @callback global_quote(String.t()) :: {:ok, map()} | {:error, String.t()}
end
