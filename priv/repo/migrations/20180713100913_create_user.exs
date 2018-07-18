defmodule Rumbl.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def up do
    execute """
    create table users(
      id serial primary key,
      name text not null,
      username text not null unique,
      password_hash text not null,

      inserted_at timestamptz not null,
      updated_at timestamptz not null
    );
    """
  end

  def down do
    execute """
    drop table users;
    """
  end
end
