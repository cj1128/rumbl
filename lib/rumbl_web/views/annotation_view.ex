defmodule RumblWeb.AnnotationView do
  use RumblWeb, :view

  def render("annotation.json", %{annotation: ann}) do
    user = Rumbl.Multimedia.get_annotation_user(ann)

    %{
      id: ann.id,
      body: ann.body,
      at: ann.at,
      user: render_one(user, RumblWeb.UserView, "user.json"),
    }
  end
end
