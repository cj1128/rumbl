defmodule RumblWeb.VideoViewTest do
  use RumblWeb.ConnCase, async: true

  import Phoenix.View

  alias Rumbl.Videos.Video
  alias Rumbl.Categories.Category

  test "render index.html", %{conn: conn} do
    videos = [
      %Video{id: 1, title: "dogs", category: %Category{}},
      %Video{id: 2, title: "cats", category: %Category{}},
    ]

    content = render_to_string(RumblWeb.VideoView, "index.html", conn: conn, videos: videos)
    assert String.contains?(content, "Listing Videos")
    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end

  test "render new.html", %{conn: conn} do
    changeset = Rumbl.Videos.change_video(%Rumbl.Videos.Video{})
    categories = [{"cats", 1}]

    content = render_to_string(RumblWeb.VideoView, "new.html",
      conn: conn,
      changeset:
      changeset, categories: categories
    )

    assert String.contains?(content, "New Video")
  end
end
