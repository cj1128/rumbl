defmodule RumblWeb.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_username_and_pass(conn, username, pass) do
    user = Rumbl.Repo.get_by(Rumbl.User, username: username)

    cond do
      user && checkpw(pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    delete_session(conn, :user_id)
  end

  ## Plugs

  def fetch_user_from_session(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Rumbl.Repo.get(Rumbl.User, user_id)
    assign(conn, :current_user, user)
  end

  def require_login(conn, _opts) do
    import Phoenix.Controller
    alias RumblWeb.Router.Helpers

    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end