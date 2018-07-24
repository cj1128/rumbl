defmodule Rumbl.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :url, :string, null: false
      add :title, :string, null: false
      add :description, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:videos, [:user_id])
  end
end
