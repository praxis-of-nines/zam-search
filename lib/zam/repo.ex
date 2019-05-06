defmodule Zam.Repo do
  use Ecto.Repo,
    otp_app: :zam,
    adapter: Ecto.Adapters.Postgres
end
