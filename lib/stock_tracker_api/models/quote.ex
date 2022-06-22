defmodule StockTrackerApi.Quote do
  @moduledoc false

  use Ecto.Schema

  alias StockTrackerApi.StockTicker

  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:change, :change_percent, :high, :latest_trading_day, :low, :open, :previous_close, :price, :volume]}
  schema "quotes" do
    field :change, :decimal
    field :change_percent, :decimal
    field :high, :decimal
    field :latest_trading_day, :date
    field :low, :decimal
    field :open, :decimal
    field :previous_close, :decimal
    field :price, :decimal
    field :volume, :integer

    belongs_to :stock_ticker, StockTicker

    timestamps()
  end

  @required_fields ~w(change change_percent high latest_trading_day low open previous_close price volume stock_ticker_id)a

  @doc false
  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [
      :change,
      :change_percent,
      :high,
      :latest_trading_day,
      :low,
      :open,
      :previous_close,
      :price,
      :volume,
      :stock_ticker_id
    ])
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:stock_ticker_id)
  end
end
