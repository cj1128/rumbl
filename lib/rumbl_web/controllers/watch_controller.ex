defmodule RumblWeb.WatchController do
  use RumblWeb, :controller

  import RumblWeb.Auth, only: [require_login: 2]

  alias Rumbl.Multimedia

  plug :require_login when action in [:show]

  def show(conn, %{"id" => id}, user) do
    video = Multimedia.get_user_video!(user, id)
    render conn, "show.html", video: video
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end
end
