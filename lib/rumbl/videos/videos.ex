defmodule Rumbl.Videos do
  import Ecto.Query
  alias Rumbl.Repo

  alias Rumbl.Videos.Video
  alias Rumbl.Account.User

  def list_user_videos(user) do
    query =
      from v in Video, where: v.user_id == ^user.id, preload: [:category]

    Repo.all query
  end

  def get_user_video!(user, id) do
    query =
      from v in Video, where: v.user_id == ^user.id, preload: [:category]

    Repo.one! query
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
end
