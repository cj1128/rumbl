defmodule Rumbl.TestUtil do
  alias Rumbl.{
    Account,
    Videos
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

    {:ok, video} = Videos.create_video(user, attrs)

    video
  end
end
