%{
  configs: [
    %{
      name: "default",
      checks: [
        {Credo.Check.Refactor.Nesting, max_nesting: 3}
      ],
      files: %{
        included: ["mix.exs", "lib/"],
        excluded: ["test/", "lib/stock_tracker_api_web/telemetry.ex"]
      }
    }
  ]
}
