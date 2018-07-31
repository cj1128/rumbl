defmodule Rumbl.VideosTest do
  use Rumbl.DataCase

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.{Category, Video}

  describe "Category" do
    test "list alphabetical categories" do
      for name <- ~w(Drama Action Comedy), do: Multimedia.create_category(%{name: name})

      alpha_names =
        for %Category{name: name} <- Multimedia.list_alphabetical_categories() do
          name
        end

      assert alpha_names == ["Action", "Comedy", "Drama"]
    end
  end

  describe "videos" do

    @valid_attrs %{description: "some description", title: "some title", url: "some url"}
    @update_attrs %{description: "some updated description", title: "some updated title", url: "some updated url"}
    @invalid_attrs %{description: nil, title: nil, url: nil}

    test "list_user_videos/0 returns user's all videos" do
      owner = user_fixture()
      %Video{id: id1} = video_fixture(owner)
      assert [%Video{id: ^id1}] = Multimedia.list_user_videos(owner)

      %Video{id: id2} = video_fixture(owner)

      assert [^id1, ^id2] =
        Multimedia.list_user_videos(owner) |> Enum.map(&(&1.id)) |> Enum.sort()
    end

    test "get_user_video!/1 returns user's video with given id" do
      owner = user_fixture()
      %Video{id: id} = video_fixture(owner)
      assert %Video{id: ^id} = Multimedia.get_user_video!(owner, id)
    end

    test "create_video/2 with valid data creates a video" do
      owner = user_fixture()
      {:ok, cate} = Multimedia.create_category(%{name: "tmp"})
      assert {:ok, %Video{} = video} = Multimedia.create_video(
        owner,
        Map.put(@valid_attrs, :category_id, cate.id)
      )

      assert video.description == "some description"
      assert video.title == "some title"
      assert video.url == "some url"
    end

    test "create_video/2 with invalid data returns error changeset" do
      owner = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Multimedia.create_video(owner, @invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      owner = user_fixture()
      video = video_fixture(owner)
      assert {:ok, video} = Multimedia.update_video(video, @update_attrs)
      assert %Video{} = video
      assert video.description == "some updated description"
      assert video.title == "some updated title"
      assert video.url == "some updated url"
    end

    test "update_video/2 with invalid data returns error changeset" do
      owner = user_fixture()
      video = video_fixture(owner)
      assert {:error, %Ecto.Changeset{}} = Multimedia.update_video(video, @invalid_attrs)
    end

    test "delete_video/1 deletes the video" do
      owner = user_fixture()
      video = video_fixture(owner)
      assert {:ok, %Video{}} = Multimedia.delete_video(video)
      assert Multimedia.list_user_videos(owner) == []
    end
  end
end
