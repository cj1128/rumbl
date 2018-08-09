defmodule Rumbl.Multimedia do
  import Ecto.Query
  alias Rumbl.Repo

  alias Rumbl.Multimedia.{Video, Category, Annotation}
  alias Rumbl.Account
  alias Rumbl.Account.User

  # Video

  def list_user_videos(user) do
    query =
      from v in Video, where: v.user_id == ^user.id, preload: [:category]

    Repo.all query
  end

  def get_user_video!(user, id) do
    query = from v in Video,
      where: v.user_id == ^user.id and v.id == ^id,
      preload: [:category]

    Repo.one! query
  end

  def get_video(id) do
    Repo.get(Video, id)
  end

  def get_video!(id) do
    Repo.get!(Video, id)
  end

  def get_video_preload(id) do
    v = Repo.get!(Video, id)
    Repo.preload(v, :user)
  end

  def create_video(%User{} = user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:videos, attrs)
    |> Video.changeset(attrs)
    |> Repo.insert()
  end

  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  def change_video(%Video{} = video) do
    Video.changeset(video, %{})
  end

  # Category

  def list_categories do
    Repo.all(Category)
  end

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def list_alphabetical_categories do
    Repo.all(from c in Category, order_by: c.name)
  end

  # Annotation

  def list_annotations do
    Repo.all(Annotation)
  end

  def get_annotation!(id), do: Repo.get!(Annotation, id)

  def get_annotation_user(annotation) do
    video = get_video(annotation.video_id)
    Account.get_user(video.user_id)
  end

  def create_annotation(video = %Video{}, attrs \\ %{}) do
    video
    |> Ecto.build_assoc(:annotations)
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  def update_annotation(%Annotation{} = annotation, attrs) do
    annotation
    |> Annotation.changeset(attrs)
    |> Repo.update()
  end

  def delete_annotation(%Annotation{} = annotation) do
    Repo.delete(annotation)
  end

  def change_annotation(%Annotation{} = annotation) do
    Annotation.changeset(annotation, %{})
  end
end
