defmodule Trashy.Repo do
  use Ecto.Repo,
    otp_app: :trashy,
    adapter: Ecto.Adapters.Postgres
end
