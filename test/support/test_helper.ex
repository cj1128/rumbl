defmodule RumblWeb.TestHelper do
  def create_user(attrs \\ %{}) do
    {:ok, user} = Rumbl.Account.create_user(Enum.into(attrs, %{
      name: "Some User",
      username: "user#{Base.encode16(:crypto.strong_rand_bytes(5))}",
      password: "password",
    }))

    user
  end
end
