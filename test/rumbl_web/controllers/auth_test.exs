defmodule Rumbl.AuthTest do
  use RumblWeb.ConnCase

  alias RumblWeb.Auth
  alias Rumbl.Account.User

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(RumblWeb.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "require_login halts when no current_user exists", %{conn: conn} do
    conn = Auth.require_login(conn, [])
    assert conn.halted
  end

  test "require_login continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %User{})
      |> Auth.require_login([])
    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%User{id: 123})
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  describe "fetch_user_from_session" do
    test "do nothing if assigns.current_user exists", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, 1)
        |> Auth.fetch_user_from_session([])

      assert conn.assigns.current_user == 1
    end

    test "place user from session into assigns", %{conn: conn} do
      user = create_user()

      conn =
        conn
        |> put_session(:user_id, user.id)
        |> Auth.fetch_user_from_session([])

      assert conn.assigns.current_user.id == user.id
    end

    test "set current_user assign to nil if no session", %{conn: conn} do
      conn = Auth.fetch_user_from_session(conn, [])

      assert conn.assigns[:current_user] == nil
    end
  end
end
