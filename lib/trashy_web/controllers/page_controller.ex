defmodule TrashyWeb.PageController do
  use TrashyWeb, :controller

  alias Trashy.Registrations
  alias Trashy.Registrations.Registration

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def organizer(conn, _params) do
    render(conn, :organizer)
  end

  def organizer_not_authorized(conn, _params) do
    render(conn, :organizer_not_authorized)
  end
end
