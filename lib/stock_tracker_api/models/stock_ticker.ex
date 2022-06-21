defmodule StockTrackerApi.StockTicker do
  @moduledoc false
  use Ecto.Schema

  alias StockTrackerApi.Quote

  import Ecto.Changeset

  schema "stock_tickers" do
    field :symbol, :string

    has_many :quotes, Quote
    timestamps()
  end

  @doc false
  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:symbol])
    |> unique_constraint(:symbol)
    |> validate_required([:symbol])
  end
end
