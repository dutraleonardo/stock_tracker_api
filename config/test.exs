import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :stock_tracker_api, StockTrackerApi.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "stock_tracker_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stock_tracker_api, StockTrackerApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "+V5jZB+wXQNNzS0E7d5kVUa15XWCr1+OVHVgSVXMBY00vY4xN0fqtl1imYVomGXI",
  server: false

# In test we don't send emails.
config :stock_tracker_api, StockTrackerApi.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilationww
config :phoenix, :plug_init_mode, :runtime

config :stock_tracker_api, StockTrackerApi.Client.Api, api_key: "TESTE_API_KEY"

config :stock_tracker_api, client_impl: ClientApiBehaviourMock

config :stock_tracker_api, StockTrackerApi.Client.Api, host: "https://www.alphavantage.co/query"

config :stock_tracker_api, StockTrackerApi.Monitor.RateLimiterServer,
  daily_limit: "500",
  minute_limit: "5",
  requests_timeframe: 60_000

config :stock_tracker_api, StockTrackerApi.MonitorServer, job_timeframe: 600_000
