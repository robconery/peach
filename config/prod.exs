use Mix.Config

config :maru, Peach.API, http: [port: 443] #make sure this is 443
config :moebius, connection: [
  database: "redfour"
]
import_config "prod.secret.exs"
