defmodule Gazerbeam.GitHub do
  @moduledoc """
  The GitHub context.
  """

  import Ecto.Query, warn: false

  alias Gazerbeam.Repo
  alias Gazerbeam.Client
  alias Gazerbeam.GitHub.{Repository, Stargazer}

  require Logger

  @doc """
  Returns the list of repositories.
  """
  def list_repositories do
    Repo.all(Repository)
  end

  @doc """
  Gets a single repository.

  Raises `Ecto.NoResultsError` if the Repository does not exist.
  """
  def get_repository!(id) do
    Repo.get!(Repository, id)
  end

  @doc """
  Creates a repository.
  """
  def create_repository(attrs \\ %{}) do
    %Repository{}
    |> Repository.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of all stargazers for a given repository.
  """
  def list_stargazers(repository_id) do
    Repo.all(from s in Stargazer, where: s.repository_id == ^repository_id)
  end

  @doc """
  Returns the stargazers for a given repository within a date range.
  """
  def list_stargazers(repository_id, start_date, end_date) do
    Repo.all(
      from s in Stargazer,
        where: s.repository_id == ^repository_id,
        where: s.starred_at >= ^start_date,
        where: s.starred_at <= ^end_date
    )
  end

  @doc """
  Syncs a given repository from the GitHub API.
  """
  def sync_repository(owner, name) do
    with {:ok, object} <- Client.impl().get_repository(owner, name) do
      object
      |> coerce_repository_to_changeset()
      |> Repo.insert()
    end
  end

  @doc """
  Syncs all stargazer data for a given repository from the GitHub API.
  """
  def sync_stargazers(%Repository{} = repository) do
    Logger.info("[#{__MODULE__}] syncing '#{repository.owner}/#{repository.name}'")

    with {:ok, objects} <- Client.impl().get_stargazers(repository.owner, repository.name) do
      stargazer_changesets =
        for object <- objects do
          object
          |> coerce_stargazer_to_changeset()
          |> Ecto.Changeset.put_change(:repository_id, repository.id)
        end

      Repo.transaction(fn ->
        # add new stargazers
        existing_github_user_ids =
          stargazer_changesets
          |> Enum.map(&Repo.insert!(&1, on_conflict: :nothing))
          |> Enum.map(& &1.github_user_id)

        # restore previously deleted stargazers
        Repo.update_all(
          from(s in Stargazer, where: s.github_user_id in ^existing_github_user_ids),
          set: [is_deleted: false]
        )

        # delete stargazers
        Repo.update_all(
          from(s in Stargazer, where: s.github_user_id not in ^existing_github_user_ids),
          set: [is_deleted: true]
        )

        # update repostiry sync timestamp
        repository
        |> Repository.changeset(%{synced_at: NaiveDateTime.utc_now()})
        |> Repo.update!()
      end)

      Logger.info("[#{__MODULE__}] completed '#{repository.owner}/#{repository.name}'")
    end
  end

  @doc """
  Syncs all stargazer data for all repositories from the GitHub API.

  Each sync is executed by a supervised `Task`.
  """
  def sync_all_repository_stargazers() do
    for repository <- list_repositories() do
      Task.Supervisor.start_child(
        Gazerbeam.SyncSupervisor,
        fn ->
          sync_stargazers(repository)
        end,
        # 10 minute timout
        timeout: 600_000
      )
    end
  end

  defp coerce_stargazer_to_changeset(object) do
    Stargazer.changeset(%Stargazer{}, %{
      starred_at: object["starred_at"],
      github_user_id: get_in(object, ["user", "id"]),
      name: get_in(object, ["user", "login"]),
      url: get_in(object, ["user", "html_url"])
    })
  end

  defp coerce_repository_to_changeset(object) do
    Repository.changeset(%Repository{}, %{
      github_id: object["id"],
      url: object["html_url"],
      owner: get_in(object, ["owner", "login"]),
      name: object["name"]
    })
  end

  @doc """
  Returns the current GitHub API rate limit
  """
  def get_rate_limit() do
    Client.impl().get_rate_limit()
  end
end
