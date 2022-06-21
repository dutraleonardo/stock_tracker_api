defmodule StockTrackerApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      StockTrackerApi.Repo,
      # Start the Telemetry supervisor
      StockTrackerApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: StockTrackerApi.PubSub},
      # Start the Endpoint (http/https)
      StockTrackerApiWeb.Endpoint,
      # Start a worker by calling: StockTrackerApi.Worker.start_link(arg)
      # {StockTrackerApi.Worker, arg}

      # Rate Limiter Server
      {StockTrackerApi.Monitor.RateLimiterServer, []},

      # Monitor worker configutations
      {Task.Supervisor, name: MonitorServer.TaskSupervisor},
      {StockTrackerApi.MonitorServer, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StockTrackerApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StockTrackerApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
