defmodule StockTrackerApi.Repo.Migrations.AddStockTickersTable do
  use Ecto.Migration

  def change do
    create table(:stock_tickers) do
      add :symbol, :string

      timestamps()
    end

    create unique_index(:stock_tickers, [:symbol])
  end
end
