defmodule RumblWeb.UserController do
  use RumblWeb, :controller

  import RumblWeb.Auth, only: [require_login: 2, login: 2]

  alias Rumbl.Account
  alias Rumbl.Account.User

  plug :require_login when action in [:index, :show]

  def index(conn, _params) do
    users = Account.list_users()
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Account.get_user!(id)
    render conn, "show.html", user: user
  end

  def new(conn, _) do
    changeset = Account.change_user(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    case Account.create_user(user_params) do
      {:ok, user} ->
        conn
        |> login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))

      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end
end
