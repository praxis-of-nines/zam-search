use Mix.Config

# Configure your database
config :zam, Zam.Repo,
  username: "user",
  password: "pass",
  database: "zam",
  hostname: "localhost",
  migration_primary_key: [
    name: :id, 
    type: :bigserial, 
    autogenerate: false, 
    read_after_writes: true],
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :khafra_search, :source_sqldb,
  adapter: :postgres,
  database: "zam",
  username: "user",
  password: "pass",
  hostname: "localhost"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :zam, ZamWeb.Endpoint,
  http: [port: 4001],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :zam, ZamWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/zam_web/{live,views}/.*(ex)$",
      ~r"lib/zam_web/templates/.*(eex)$",
      ~r{lib/my_app_web/live/.*(ex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
