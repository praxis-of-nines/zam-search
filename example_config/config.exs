# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :zam, Zam.Repo,
  database: "zam_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :zam,
  ecto_repos: [Zam.Repo],
  user_agent: "Zambot/0.1"

# Configures the endpoint
config :zam, ZamWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "secretivekey!",
  render_errors: [view: ZamWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Zam.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# LiveView
config :zam, ZamWeb.Endpoint,
   live_view: [
     signing_salt: "saltysigning!"
   ]

# SSX
config :simplestatex,
  repo: Zam.Repo

# KHAFRA SEARCH
config :khafra_search, Khafra.Scheduler,
  timezone: "America/Los_Angeles",
  global: true,
  timeout: :infinity,
  jobs: [
    {"45 * * * *", {Khafra.Job.Index, :run, [
      [{:option, "--rotate"}, {:option, "--all"}]
    ]}}
  ]

# Indexer settings
config :khafra_search, :indexer,
  mem_limit: "256M"

# Search Daemon settings
config :khafra_search, :searchd,
  listen_sphinx: "9312",
  listen_mysql: "9306:mysql41",
  log: "[cwd!]/sphinx/log/searchd.log",
  query_log: "[cwd!]/sphinx/log/query.log",
  binlog_path: "[cwd!]/sphinx/data",
  pid_file: "[cwd!]/sphinx/data/searchd.pid",
  read_timeout: "2"

# Common index defaults: by default the parent of any index created
config :khafra_search, :index_defaults,
  type: "plain",
  source: {:sql, :source_sqldb},
  morphology: "none",
  min_stemming_len: "1",
  min_word_len: "1",
  min_infix_len: "2",
  html_strip: "0",
  preopen: "0",
  wordforms: "[cwd!]/sphinx/wordforms.txt"

import_config "source_weblink.exs"

config :khafra_search, :i_weblink,
  parent: :index_defaults,
  source: :source_weblink

config :khafra_search,
  indices: [
    :i_weblink
  ]

config :zam, Zam.Scheduler,
  global: true,
  jobs: [
    {"@hourly",  {Zam.Crawler, :crawl, [:hourly]}},
    {"@daily",   {Zam.Crawler, :crawl, [:daily]}},
    {"@weekly",  {Zam.Crawler, :crawl, [:weekly]}},
    {"@monthly", {Zam.Crawler, :crawl, [:monthly]}}
  ]


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
