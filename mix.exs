defmodule Zam.MixProject do
  use Mix.Project

  def project do
    [
      app: :zam,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Zam.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.8"},
      {:phoenix_live_view, "~> 0.15.4"},
      {:phoenix_live_dashboard, "~> 0.4.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:timex, "~> 3.6"},
      {:plug_cowboy, "~> 2.4"},
      {:phoenix_ecto, "~> 4.1"},
      {:postgrex, "~> 0.15.1"},
      {:ecto_sql, "~> 3.4"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:httpoison, "~> 1.3", override: true},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.2"},
      {:gen_stage, "~> 0.12.2", override: true},
      {:poison, "~> 4.0", override: true},
      # Note: this shouldn't be necessary but crawlies flow isn't deploying
      {:flow, "~> 0.12.0"},
      # Deployment
      {:distillery, "~> 2.0"},
      {:edeliver, "~> 1.8"},
      # Statistics and Indexing
      #{:khafra_search, path: "../khafra-search"},
      {:khafra_search, "~> 0.2.1"},
      #{:simplestatex, path: "../simplestatex"},
      {:simplestatex, "~> 0.3.0"},
      #{:giza_sphinxsearch, path: "../giza_sphinxsearch"}
      {:giza_sphinxsearch, "~> 1.0.7"},
      # Crawling and Parsing
      {:crawlie, "~> 1.0.0"},
      {:floki, "~> 0.29.0"},
      #{:html5ever, "~> 0.8.0"},
      {:quantum, "~> 2.4"},
      {:fast_sanitize, "~> 0.2.2"},
      # Clock
      {:enoch_ex, path: "../enoch_ex"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
