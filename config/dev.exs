use Mix.Config

config :moebius, connection: [
  database: "redfour"
]

config :maru, Peach.API,
    http: [port: 8080],
    versioning: [using: :path]

import_config "dev.secret.exs"
