defmodule Mix.Tasks.Gazerbeam do
  @moduledoc """
  `Mix.Task` for manually invoking jobs when developing `Gazerbeam`

  ## Arguments

  - `sync_one`: syncs all stargazers for the given repository
  - `sync_all`: syncs all stargazers for all repositories
  - `get_rate_limit`: displays the current GitHub API rate-limit
  """
  @shortdoc "Execute Gazerbeam jobs for development and testing"

  use Mix.Task

  @impl true
  def run(["sync_one", repository_id]) do
    {:ok, _apps} = Application.ensure_all_started(:gazerbeam)

    repository_id
    |> Gazerbeam.GitHub.get_repository!()
    |> Gazerbeam.GitHub.sync_stargazers()
  end

  def run(["sync_all"]) do
    {:ok, _apps} = Application.ensure_all_started(:gazerbeam)

    for repository <- Gazerbeam.GitHub.list_repositories() do
      Gazerbeam.GitHub.sync_stargazers(repository)
    end
  end

  def run(["get_rate_limit"]) do
    {:ok, _apps} = Application.ensure_all_started(:gazerbeam)

    {:ok, %{"rate" => %{"limit" => limit, "used" => used}}} = Gazerbeam.GitHub.get_rate_limit()

    Mix.shell().info("GitHub API rate-limit #{used}/#{limit}")
  end

  def run(_) do
    Mix.Task.run("help", ["gazerbeam"])
  end
end
