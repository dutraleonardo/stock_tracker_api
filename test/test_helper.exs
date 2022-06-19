Mox.defmock(ClientApiBehaviourMock, for: StockTrackerApi.Client.ApiBehaviour)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(StockTrackerApi.Repo, :manual)
