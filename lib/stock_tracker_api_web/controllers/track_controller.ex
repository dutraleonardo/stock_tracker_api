defmodule StockTrackerApiWeb.TrackController do
  @moduledoc """
  This module contains a controller funtionc that returns if app and database are running properly.
  """
  use StockTrackerApiWeb, :controller

  alias StockTrackerApi.MonitorServer

  def create(conn, %{"stock_ticker" => symbol}) do
    MonitorServer.make_request(:global_quote, symbol)

    conn
    |> put_status(:ok)
    |> json(%{
      msg: "Monitoring created for #{symbol} and will run every 10 minutes."
    })
  end
end
