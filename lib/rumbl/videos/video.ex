defmodule Rumbl.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @all_attrs [:url, :title, :description, :category_id]
  @required_attrs [:title, :url]

  schema "videos" do
    field :description, :string
    field :title, :string
    field :url, :string

    belongs_to :user, Rumbl.Account.User
    belongs_to :category, Rumbl.Categories.Category

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, @all_attrs)
    |> validate_required(@required_attrs)
    |> assoc_constraint(:category)
  end
end
