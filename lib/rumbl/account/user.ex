defmodule Rumbl.Account.User do
  use Ecto.Schema

  import Ecto.{Changeset}

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :videos, Rumbl.Multimedia.Video

    timestamps()
  end

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, ~w(name username))
    |> unique_constraint(:username, name: :users_username_key)
    |> validate_required([:name, :username])
    |> validate_length(:username, max: 20)
  end

  def password_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password))
    |> validate_required(:password)
    |> validate_length(:password, min: 6, max: 20)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
