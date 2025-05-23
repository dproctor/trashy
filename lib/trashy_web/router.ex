defmodule TrashyWeb.Router do
  use TrashyWeb, :router

  import TrashyWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {TrashyWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", TrashyWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
    get("/event_participants/checkin/:event_id/:code", EventParticipantController, :checkin)

    put(
      "/event_participants/checkin/:event_id/:code/record_attendance",
      EventParticipantController,
      :record_attendance
    )

    live("/event_participants/certificate/:participant_id/:code", CertificateLive)

    post "/registrations", RegistrationController, :create

    get("/not_authorized", PageController, :organizer_not_authorized)
  end

  scope "/organizer", TrashyWeb do
    pipe_through([:browser, :require_authenticated_user, :require_organizer])

    get("/", PageController, :organizer)
    resources("/cleanups", CleanupController)
    resources("/promotions", PromotionController)

    resources "/events", EventController do
      resources("/event_participants", EventParticipantController)
    end

    get("/events/qr_code/:url", EventController, :qr_code)
    get("/events/poster/:event_id", EventController, :poster)
    get("/events/certificate/:event_id", EventController, :certificate)

    get("/cleanups/:cleanup_id/events", CleanupController, :events)
  end

  scope "/admin", TrashyWeb do
    pipe_through([:browser, :require_authenticated_user, :require_admin])

    get("/", PageController, :admin)
    resources "/users", UserController
    get "/new_cleanup", CleanupController, :new
  end

  # Other scopes may use custom stacks.
  # scope "/api", TrashyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:trashy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: TrashyWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", TrashyWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TrashyWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", TrashyWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{TrashyWeb.UserAuth, :ensure_authenticated}] do
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)
    end
  end

  scope "/", TrashyWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{TrashyWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end
end
