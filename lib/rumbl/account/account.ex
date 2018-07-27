defmodule Rumbl.Account do
  alias Rumbl.Account.User
  alias Rumbl.Repo

  def list_users do
    Repo.all(User)
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.password_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(username, pass) do
    user = get_user_by(username: username)

    cond do
      user && Comeonin.Bcrypt.checkpw(pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        {:error, :not_found}
    end
  end
end
