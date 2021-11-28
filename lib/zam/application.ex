defmodule Zam.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  alias Khafra.Job.Searchd
  alias Phoenix
  alias Phoenix.PubSub

  def start(_type, _args) do
    import Supervisor.Spec

    # List all child processes to be supervised
    children = [
      Zam.Repo,
      ZamWeb.Telemetry,
      {Phoenix.PubSub, name: Zam.PubSub},
      ZamWeb.Endpoint,
      Giza.Application,
      supervisor(Khafra.Application, []),
      Zam.Scheduler,
      supervisor(EnochEx.Application, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zam.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def on_reboot() do
    # Start Search Daemon
    _ = Searchd.run([])
    # Start Default Calendar
    broadcast = fn cdt ->
      PubSub.broadcast(Zam.PubSub, "calendar_ticker", cdt)
    end

    _ = EnochEx.start_calendar(tick_callback: broadcast)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ZamWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
