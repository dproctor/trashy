defmodule Trashy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TrashyWeb.Telemetry,
      # Start the Ecto repository
      Trashy.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Trashy.PubSub},
      # Start Finch
      {Finch, name: Trashy.Finch},
      # Start the Endpoint (http/https)
      TrashyWeb.Endpoint,
      # Start a worker by calling: Trashy.Worker.start_link(arg)
      # {Trashy.Worker, arg}
      # 2 hours
      {Trashy.CronWorker, 2 * 60 * 60 * 1000}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Trashy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TrashyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
