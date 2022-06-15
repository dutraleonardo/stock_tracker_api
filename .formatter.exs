# Used by "mix format"
[
  import_deps: [:ecto, :phoenix],
  inputs: ["{mix,.formatter}.exs", "*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 120,
  subdirectories: ["priv/*/migrations"]
]
