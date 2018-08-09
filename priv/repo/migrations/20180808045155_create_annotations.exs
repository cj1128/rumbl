defmodule Rumbl.Repo.Migrations.CreateAnnotations do
  use Ecto.Migration

  def change do
    create table(:annotations) do
      add :body, :text, null: false
      add :at, :integer, null: false
      add :video_id, references(:videos, on_delete: :nothing), null: false

      timestamps(type: :timestamptz)
    end

    create index(:annotations, [:video_id])
  end
end
