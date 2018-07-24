defmodule RumblWeb.Router do
  use RumblWeb, :router

  import RumblWeb.Auth, only: [fetch_user_from_session: 2, require_login: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug :fetch_user_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RumblWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/users", UserController, only: [:index, :show, :new, :create]

    resources "/sessions", SessionController,
      only: [:new, :create, :delete],
      singleton: true
  end

  scope "/manage", RumblWeb do
    pipe_through [:browser, :require_login]

    resources "/videos", VideoController
  end
end
