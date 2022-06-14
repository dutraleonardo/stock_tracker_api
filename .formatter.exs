[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 120,
  subdirectories: ["priv/*/migrations"],
  export: [
    locals_without_parens: [add: 2, add: 3]
  ]
]
