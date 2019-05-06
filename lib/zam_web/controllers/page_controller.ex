defmodule ZamWeb.PageController do
  use ZamWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
