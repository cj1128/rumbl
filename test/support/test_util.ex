defmodule Rumbl.TestUtil do
  alias Rumbl.{
    Account,
    Multimedia,
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "Some User",
        username: "user#{Base.encode16(:crypto.strong_rand_bytes(5))}",
        password: "password",
      })
      |> Account.create_user()

    user
  end

  def video_fixture(%Account.User{} = user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "title",
        url: "url",
        description: "description",
      })

    category_id =
      if attrs[:category_id] do
        attrs[:category_id]
      else
        case Multimedia.list_categories() do
          [] ->
            {:ok, cate} = Multimedia.create_category(%{name: "tmp"})
            cate.id
          [h|t] ->
            h.id
        end
      end

    attrs = Map.put(attrs, :category_id, category_id)

    {:ok, video} = Multimedia.create_video(user, attrs)

    video
  end
end
