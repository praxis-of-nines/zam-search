defmodule ZamWeb.PageController do
  use ZamWeb, :controller

  def index(conn, _params) do
    conn    
    |> render("index.html")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def paiza(conn, _params) do
    render(conn, "paiza.html")
  end

  def challenge(conn, _params) do
    render(conn, "challenge.html")
  end
end
