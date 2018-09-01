defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  import Ecto.Query

  alias Rumbl.{Repo, Account, Multimedia}
  alias RumblWeb.AnnotationView

  def join("videos:" <> video_id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Multimedia.get_video!(video_id)

    annotations = Repo.all(
      from a in Ecto.assoc(video, :annotations),
        where: a.id > ^last_seen_id,
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

  def handle_in("new_annotation", params, socket) do
    case Multimedia.create_annotation(
      socket.assigns.user_id, 
      socket.assigns.video_id, 
      params
    ) do
      {:ok, ann} ->
        broadcast_annotation(socket, ann)

        Task.start_link(fn -> compute_additional_info(ann, socket) end)

        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_annotation(socket, ann) do
    rendered = Phoenix.View.render(AnnotationView, "annotation.json", %{annotation: ann})
    broadcast! socket, "new_annotation", rendered   
  end

  defp compute_additional_info(ann, socket) do
    for result <- Rumbl.InfoSys.compute(ann.body, limit: 1, timeout: 10_000) do
      attrs = %{url: result.url, body: result.text, at: ann.at}
      user = Account.get_user_by(username: result.backend)
      case Multimedia.create_annotation(
        user.id,
        socket.assigns.video_id,
        attrs
      ) do
        {:ok, info_ann} -> broadcast_annotation(socket, info_ann)
        {:error, _changeset} -> :ignore
      end  
    end
  end
end
