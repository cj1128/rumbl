defmodule Rumbl.Repo.Migrations.SetDefaultValueForVideo do
  use Ecto.Migration

  def up do
    execute "alter table videos alter url set default ''"
  end

  def down do
    execute "alter table videos alter column url drop default"
  end
end
