defmodule StockTrackerApiWeb.HealthCheckController do
@moduledoc """
This module contains a controller funtionc that returns if app and database are running properly.
"""
  use StockTrackerApiWeb, :controller

  def health(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{
      app: app_status(),
      database: database_status()
    })
  end

  defp app_status do
    %{
      message: "Application is running",
      success: true
    }
  end

  defp database_status do
    if StockTrackerApi.Repo.connected?() do
      %{
        message: "Database is connected",
        success: true
      }
    else
      %{
        message: "Error connecting to database",
        success: false
      }
    end
  end
end
