defmodule StockTrackerApiWeb.StockTickerController do
  @moduledoc """
  This module contains a controller funtionc that returns if app and database are running properly.
  """
  use StockTrackerApiWeb, :controller

  alias StockTrackerApi.MonitorServer
  alias StockTrackerApi.QuoteRepo

  import Plug.Conn

  def create(conn, %{"stock_ticker" => symbol}) do
    MonitorServer.make_request(:global_quote, symbol)

    conn
    |> put_status(:ok)
    |> json(%{
      msg: "Monitoring created for #{symbol} and will run every 10 minutes."
    })
  end

  def search(conn, params) do
    result = QuoteRepo.filter(params)

    conn
    |> put_status(:ok)
    |> put_resp_content_type("application/json")
    |> render("quotes.json", %{quotes: result})
  end
end
