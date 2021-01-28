defmodule GazerbeamWeb.RepositoryView do
  use GazerbeamWeb, :view
  alias GazerbeamWeb.RepositoryView

  def render("index.json", %{repositories: repositories}) do
    %{data: render_many(repositories, RepositoryView, "repository.json")}
  end

  def render("show.json", %{repository: repository}) do
    %{data: render_one(repository, RepositoryView, "repository.json")}
  end

  def render("repository.json", %{repository: repository}) do
    %{
      id: repository.id,
      github_id: repository.github_id,
      url: repository.url,
      owner: repository.owner,
      name: repository.name,
      synced_at: repository.synced_at
    }
  end
end
