use Mix.Config
config :maru, Peach.API, http: [port: 8880]
config :moebius, connection: [database: "redfour"]
import_config "test.secret.exs"
