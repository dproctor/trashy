defmodule TrashyWeb.PageController do
  use TrashyWeb, :controller

  alias Trashy.Registrations
  alias Trashy.Registrations.Registration

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    cleanups = Trashy.Cleanups.list_cleanups()
    changeset = Registrations.change_registration(%Registration{})

    render(conn, :home,
      layout: false,
      changeset: Phoenix.HTML.FormData.to_form(changeset, as: "registration"),
      cleanups: cleanups
    )
  end

  def organizer(conn, _params) do
    render(conn, :organizer)
  end
end
