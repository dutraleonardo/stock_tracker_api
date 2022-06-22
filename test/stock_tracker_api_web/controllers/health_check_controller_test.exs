defmodule StockTrackerApiWeb.HealthCheckControllerTest do
  use StockTrackerApiWeb.ConnCase
  use ExUnit.Case, async: false

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "health" do
    test "GET /health", %{conn: conn} do
      conn = get(conn, Routes.health_check_path(conn, :health))

      assert json_response(conn, 200)["app"]["success"]
      assert json_response(conn, 200)["database"]["success"]
    end
  end
end
