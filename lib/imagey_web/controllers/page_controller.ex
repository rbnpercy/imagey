defmodule ImageyWeb.PageController do
  use ImageyWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
