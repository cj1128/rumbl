defmodule Rumbl.Multimedia.Annotation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "annotations" do
    field :at, :integer
    field :body, :string

    belongs_to :video, Rumbl.Multimedia.Video
    belongs_to :user, Rumbl.Account.User

    timestamps()
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [:body, :at])
    |> validate_required([:body, :at])
    |> assoc_constraint(:video)
    |> assoc_constraint(:user)
  end
end
