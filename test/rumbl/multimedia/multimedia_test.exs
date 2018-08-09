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

  describe "annotations" do
    alias Rumbl.Multimedia.Annotation

    @valid_attrs %{at: 42, body: "some body"}
    @update_attrs %{at: 43, body: "some updated body"}
    @invalid_attrs %{at: nil, body: nil}

    def annotation_fixture(attrs \\ %{}) do
      {:ok, annotation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Multimedia.create_annotation()

      annotation
    end

    test "list_annotations/0 returns all annotations" do
      annotation = annotation_fixture()
      assert Multimedia.list_annotations() == [annotation]
    end

    test "get_annotation!/1 returns the annotation with given id" do
      annotation = annotation_fixture()
      assert Multimedia.get_annotation!(annotation.id) == annotation
    end

    test "create_annotation/1 with valid data creates a annotation" do
      assert {:ok, %Annotation{} = annotation} = Multimedia.create_annotation(@valid_attrs)
      assert annotation.at == 42
      assert annotation.body == "some body"
    end

    test "create_annotation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Multimedia.create_annotation(@invalid_attrs)
    end

    test "update_annotation/2 with valid data updates the annotation" do
      annotation = annotation_fixture()
      assert {:ok, annotation} = Multimedia.update_annotation(annotation, @update_attrs)
      assert %Annotation{} = annotation
      assert annotation.at == 43
      assert annotation.body == "some updated body"
    end

    test "update_annotation/2 with invalid data returns error changeset" do
      annotation = annotation_fixture()
      assert {:error, %Ecto.Changeset{}} = Multimedia.update_annotation(annotation, @invalid_attrs)
      assert annotation == Multimedia.get_annotation!(annotation.id)
    end

    test "delete_annotation/1 deletes the annotation" do
      annotation = annotation_fixture()
      assert {:ok, %Annotation{}} = Multimedia.delete_annotation(annotation)
      assert_raise Ecto.NoResultsError, fn -> Multimedia.get_annotation!(annotation.id) end
    end

    test "change_annotation/1 returns a annotation changeset" do
      annotation = annotation_fixture()
      assert %Ecto.Changeset{} = Multimedia.change_annotation(annotation)
    end
  end
end
