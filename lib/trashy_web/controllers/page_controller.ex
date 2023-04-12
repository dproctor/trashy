defmodule TrashyWeb.PageController do
  use TrashyWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def organizer(conn, _params) do
    render(conn, :organizer)
  end
end
