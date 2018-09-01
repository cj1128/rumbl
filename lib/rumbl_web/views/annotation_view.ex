defmodule RumblWeb.AnnotationView do
  use RumblWeb, :view

  def render("annotation.json", %{annotation: ann}) do
    ann = Rumbl.Repo.preload(ann, :user)

    %{
      id: ann.id,
      body: ann.body,
      at: ann.at,
      user: render_one(ann.user, RumblWeb.UserView, "user.json"),
    }
  end
end
