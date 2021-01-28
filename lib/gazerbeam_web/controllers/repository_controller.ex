defmodule GazerbeamWeb.RepositoryController do
  use GazerbeamWeb, :controller

  alias Gazerbeam.GitHub

  action_fallback GazerbeamWeb.FallbackController

  def index(conn, _params) do
    repositories = GitHub.list_repositories()
    render(conn, "index.json", repositories: repositories)
  end

  def create(conn, %{"owner" => owner, "name" => name}) do
    with {:ok, repository} <- GitHub.sync_repository(owner, name) do
      conn
      |> put_status(:created)
      |> render("show.json", repository: repository)
    end
  end
end
