defmodule Gazerbeam.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :gazerbeam,
    adapter: Ecto.Adapters.Postgres
end
