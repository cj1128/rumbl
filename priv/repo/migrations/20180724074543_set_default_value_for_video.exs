defmodule Rumbl.Repo.Migrations.SetDefaultValueForVideo do
  use Ecto.Migration

  def up do
    execute "alter table videos alter description set default ''"
  end

  def down do
    execute "alter table videos alter column description drop default"
  end
end
