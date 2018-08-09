defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  import Ecto.Query

  alias Rumbl.{Repo, Account, Multimedia}

  alias RumblWeb.AnnotationView

  def join("videos:" <> video_id, _params, socket) do
    video_id = String.to_integer(video_id)
    video = Multimedia.get_video!(video_id)

    annotations = Repo.all(
      from a in Ecto.assoc(video, :annotations),
        order_by: [asc: a.at, asc: a.id],
        limit: 200
    )

    resp = %{
      annotations: Phoenix.View.render_many(
        annotations,
        AnnotationView,
        "annotation.json"
      ),
    }

    {:ok, resp, assign(socket, :video_id, video_id)}
  end

  def handle_in(event, params, socket) do
    video = Multimedia.get_video_preload(socket.assigns.video_id)
    handle_in(event, params, video, socket)
  end

  def handle_in("new_annotation", params, video, socket) do
    case Multimedia.create_annotation(video, params) do
      {:ok, annotation} ->
        broadcast! socket, "new_annotation", %{
          id: annotation.id,
          user: RumblWeb.UserView.render("user.json", %{user: video.user}),
          body: annotation.body,
          at: annotation.at,
        }

        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
