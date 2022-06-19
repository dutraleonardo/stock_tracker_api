defmodule StockTrackerApi.ClientBehaviour do
  @moduledoc false
  @callback global_quote(String.t()) :: tuple()
end
