defmodule BackendWeb.PageController do
  use BackendWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def elm_app(conn, _params) do
    json(conn, %{status: "ok"})
  end

  def health(conn, _params) do
    json(conn, %{status: "ok", service: "pacemate-backend"})
  end
end
