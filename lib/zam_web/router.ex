defmodule ZamWeb.Router do
  use ZamWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ZamWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ZamWeb do
    pipe_through [:browser]

    live "/images", Live.ImageSearchResultsLive, :index
    live "/", Live.SearchResultsLive, :index
  end

  scope "/", ZamWeb do
    pipe_through :browser

    get "/about", PageController, :about
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: GabblerWeb.Telemetry
    end
  end
end
