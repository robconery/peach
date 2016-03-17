use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :web, Bigmachine.Web.Endpoint,
  secret_key_base: "0SPGllQlen9DmRADKPN+EMLKfev2bkNHLVbcd4+zD9UZ9Ibk4eXj4Kb01TViThRu"

config :moebius, connection: [database: "redfour"]
