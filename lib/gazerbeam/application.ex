defmodule Gazerbeam.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Gazerbeam.Repo,
      GazerbeamWeb.Endpoint,
      Gazerbeam.Scheduler,
      {Task.Supervisor, name: Gazerbeam.SyncSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: Gazerbeam.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    GazerbeamWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
