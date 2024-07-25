defmodule PhoenixPlayground.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_playground,
    adapter: Ecto.Adapters.Postgres
end
