defmodule StockTrackerApi.Repo do
  use Ecto.Repo,
    otp_app: :stock_tracker_api,
    adapter: Ecto.Adapters.Postgres
end
