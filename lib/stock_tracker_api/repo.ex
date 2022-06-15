defmodule StockTrackerApi.Repo do
  use Ecto.Repo,
    otp_app: :stock_tracker_api,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Tests connection with database and returns true if successful
  """
  @spec connected?() :: boolean()
  def connected? do
    case Ecto.Adapters.SQL.query(__MODULE__, "SELECT 1") do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
