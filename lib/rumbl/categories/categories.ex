defmodule Rumbl.Categories do
  import Ecto.Query
  alias Rumbl.Repo

  alias Rumbl.Categories.Category

  def get_names_and_ids() do
    query = from c in Category, order_by: c.name, select: {c.name, c.id}
    Repo.all query
  end

  def list_categories do
    Repo.all(Category)
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end
end
