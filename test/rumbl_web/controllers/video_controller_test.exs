defmodule RumblWeb.VideoControllerTest do
  use RumblWeb.ConnCase

  alias Rumbl.Multimedia

  @create_attrs %{description: "some description", title: "some title", url: "some url"}
  @update_attrs %{description: "some updated description", title: "some updated title", url: "some updated url"}
  @invalid_attrs %{title: nil, url: nil}

  describe "Access Control" do
    test "require user logged in on all actions", %{conn: conn} do
      Enum.each([
        get(conn, video_path(conn, :index)),
        get(conn, video_path(conn, :new)),
        post(conn, video_path(conn, :create), %{}),
        get(conn, video_path(conn, :show, 123)),
        get(conn, video_path(conn, :edit, 123)),
        patch(conn, video_path(conn, :update, 123), %{}),
        delete(conn, video_path(conn, :delete, 123)),
      ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
    end

    test "authorize actions against access by other users", %{conn: conn} do
      user = user_fixture()
      video = video_fixture(user)
      non_owner = user_fixture(username: "other")

      conn = assign(conn, :current_user, non_owner)

      assert_error_sent :not_found, fn ->
        get conn, video_path(conn, :show, video)
      end

      assert_error_sent :not_found, fn ->
        get conn, video_path(conn, :edit, video)
      end

      assert_error_sent :not_found, fn ->
        patch conn, video_path(conn, :update, video), video: @create_attrs
      end

      assert_error_sent :not_found, fn ->
        delete conn, video_path(conn, :delete, video)
      end
    end
  end

  describe "Index" do
    setup [:log_user_in]

    test "list all videos", %{conn: conn, user: user} do
      user_video = video_fixture(user, title: "title1")
      other_video = video_fixture(user_fixture(username: "other"), title: "title2")

      conn = get conn, video_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Videos"
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end
  end

  describe "New" do
    setup [:log_user_in]

    test "renders form", %{conn: conn} do
      conn = get conn, video_path(conn, :new)
      assert html_response(conn, 200) =~ "New Video"
    end
  end

  describe "Create" do
    setup [:log_user_in]

    test "redirects to show when data is valid", %{conn: conn, user: user} do
      {:ok, cate} = Multimedia.create_category(%{name: "tmp"})
      next_conn = post conn, video_path(conn, :create), video: Map.put(@create_attrs, :category_id, cate.id)

      assert %{id: id} = redirected_params(next_conn)
      assert redirected_to(next_conn) == video_path(conn, :show, id)

      assert Multimedia.get_user_video!(user, id)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, video_path(conn, :create), video: @invalid_attrs
      assert html_response(conn, 200) =~ "New Video"
    end
  end

  describe "Edit" do
    setup [:log_user_in]

    test "renders form for editing chosen video", %{conn: conn, user: user} do
      video = video_fixture(user)
      conn = get conn, video_path(conn, :edit, video)
      assert html_response(conn, 200) =~ "Edit Video"
    end
  end

  describe "Patch" do
    setup [:log_user_in]

    test "redirects when data is valid", %{conn: conn, user: user} do
      video = video_fixture(user)
      back_conn = patch conn, video_path(conn, :update, video), video: @update_attrs
      assert redirected_to(back_conn) == video_path(back_conn, :show, video)

      conn = get conn, video_path(conn, :show, video)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      video = video_fixture(user)
      conn = patch conn, video_path(conn, :update, video), video: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Video"
    end
  end

  describe "Delete" do
    setup [:log_user_in]

    test "deletes chosen video", %{conn: conn, user: user} do
      video = video_fixture(user)
      back_conn = delete conn, video_path(conn, :delete, video)
      assert redirected_to(back_conn) == video_path(conn, :index)

      assert_error_sent 404, fn ->
        get conn, video_path(conn, :show, video)
      end
    end
  end

  defp log_user_in(%{conn: conn} ) do
    user = user_fixture(username: "user")
    new_conn = assign(conn, :current_user, user)

    %{conn: new_conn, user: user}
  end
end
