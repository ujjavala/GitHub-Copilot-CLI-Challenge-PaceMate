defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BackendWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BackendWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/dashboard", DashboardLive
  end

  scope "/api", BackendWeb do
    pipe_through :api

    get "/health", PageController, :health
    get "/analytics/summary", AnalyticsController, :summary
    get "/sessions/history", SessionController, :history
  end

  scope "/", BackendWeb do
    pipe_through :api

    get "/elm-app", PageController, :elm_app
  end
end
