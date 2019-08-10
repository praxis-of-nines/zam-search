defmodule ZamWeb.Router do
  use ZamWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ZamWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/paiza", PageController, :paiza
  end

  # Other scopes may use custom stacks.
  # scope "/api", ZamWeb do
  #   pipe_through :api
  # end
end
