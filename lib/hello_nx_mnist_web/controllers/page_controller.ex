defmodule HelloNxMnistWeb.PageController do
  use HelloNxMnistWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
