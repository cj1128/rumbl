defmodule Rumbl.Multimedia.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @all_attrs [:url, :title, :description, :category_id, :slug]
  @required_attrs [:title, :url, :category_id]

  @primary_key {:id, Rumbl.Permanlink, autogenerate: true}
  schema "videos" do
    field :description, :string, default: ""
    field :title, :string
    field :url, :string
    field :slug, :string

    belongs_to :user, Rumbl.Account.User
    belongs_to :category, Rumbl.Multimedia.Category

    has_many :annotations, Rumbl.Multimedia.Annotation

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, @all_attrs)
    |> validate_required(@required_attrs)
    |> slugify_title()
    |> assoc_constraint(:category)
  end

  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end

defimpl Phoenix.Param, for: Rumbl.Multimedia.Video do
  def to_param(%{slug: slug, id: id}) do
    "#{id}-#{slug}"
  end
end
