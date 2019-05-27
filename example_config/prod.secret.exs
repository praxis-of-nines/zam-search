# In this file, we load production configuration and
# secrets from environment variables. You can also
# hardcode secrets, although such is generally not
# recommended and you have to remember to add this
# file to your .gitignore.
use Mix.Config

config :zam, Zam.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "user",
  password: "pass",
  database: "zam",
  hostname: "someawsaddressmaybe.someregion.rds.amazonaws.com",
  migration_primary_key: [
    name: :id, 
    type: :bigserial, 
    autogenerate: false, 
    read_after_writes: true],
  show_sensitive_data_on_connection_error: false,
  pool_size: 20

config :khafra_search, :source_sqldb,
  adapter: :postgres,
  database: "zam",
  username: "user",
  password: "pass",
  hostname: "someawsaddressmaybe.someregion.rds.amazonaws.com"

config :zam, ZamWeb.Endpoint,
  secret_key_base: "incrediblysecretbasewhichshouldbekeptinenv"
