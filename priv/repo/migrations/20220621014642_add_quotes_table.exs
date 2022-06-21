defmodule StockTrackerApi.Repo.Migrations.AddQuotesTable do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :change, :decimal
      add :change_percent, :decimal
      add :high, :decimal
      add :latest_trading_day, :date
      add :low, :decimal
      add :open, :decimal
      add :previous_close, :decimal
      add :price, :decimal
      add :volume, :integer

      add :stock_ticker_id, references(:stock_tickers)

      timestamps()
    end

    create index(:quotes, [:stock_ticker_id])
  end
end
