defmodule GazerbeamWebTest do
  alias Gazerbeam.Client.GitHubMock
  alias Gazerbeam.GitHub

  import NaiveDateTime

  use GazerbeamWeb.ConnCase

  @stargazer_1_id 1
  @stargazer_1_name "robertparr"
  @stargazer_1_url "https://github.com/#{@stargazer_1_name}"
  @stargazer_1_starred_at new!(1950, 1, 1, 0, 0, 0)

  @stargazer_2_id 2
  @stargazer_2_name "helenparr"
  @stargazer_2_url "https://github.com/#{@stargazer_2_name}"
  @stargazer_2_starred_at new!(1955, 1, 1, 0, 0, 0)

  @stargazer_3_id 3
  @stargazer_3_name "buddypine"
  @stargazer_3_url "https://github.com/#{@stargazer_3_name}"
  @stargazer_3_starred_at new!(1960, 1, 1, 0, 0, 0)

  @repo_id 4
  @repo_owner "connorlay"
  @repo_name "gazerbeam"
  @repo_url "https://github.com/#{@repo_owner}/#{@repo_name}"

  # verify mocks have been called
  setup :verify_on_exit!

  test "Gazerbeam Integration Test", %{conn: conn} do
    # GitHub API returns repository metadata
    expect(GitHubMock, :get_repository, fn @repo_owner, @repo_name ->
      data = %{
        "id" => @repo_id,
        "html_url" => @repo_url,
        "owner" => %{"login" => @repo_owner},
        "name" => @repo_name
      }

      {:ok, data}
    end)

    # track the repository in Gazerbeam
    assert %{"data" => repository} =
             conn
             |> post("/api/repositories", %{owner: @repo_owner, name: @repo_name})
             |> json_response(201)

    # verify GitHub repository data is returned
    assert repository["github_id"] == @repo_id
    assert repository["owner"] == @repo_owner
    assert repository["name"] == @repo_name
    assert repository["url"] == @repo_url
    assert repository["synced_at"] == nil

    # there are initially no stargazers watching the repository
    assert %{"data" => []} =
             conn
             |> get("/api/repositories/#{repository["id"]}/stargazers")
             |> json_response(200)

    # GitHub API returns a list of stargazers for the repository
    expect(GitHubMock, :get_stargazers, fn @repo_owner, @repo_name ->
      data = [
        %{
          "user" => %{
            "id" => @stargazer_1_id,
            "login" => @stargazer_1_name,
            "html_url" => @stargazer_1_url
          },
          "starred_at" => to_iso8601(@stargazer_1_starred_at)
        },
        %{
          "user" => %{
            "id" => @stargazer_2_id,
            "login" => @stargazer_2_name,
            "html_url" => @stargazer_2_url
          },
          "starred_at" => to_iso8601(@stargazer_2_starred_at)
        },
        %{
          "user" => %{
            "id" => @stargazer_3_id,
            "login" => @stargazer_3_name,
            "html_url" => @stargazer_3_url
          },
          "starred_at" => to_iso8601(@stargazer_3_starred_at)
        }
      ]

      {:ok, data}
    end)

    # sync all stargazers for the repository
    repository["id"]
    |> GitHub.get_repository!()
    |> GitHub.sync_stargazers()

    # fetched the newly synced repository
    assert %{"data" => [repository]} =
             conn
             |> get("/api/repositories")
             |> json_response(200)

    # the repository synced_at timestamp was set
    assert repository["github_id"] == @repo_id
    assert repository["owner"] == @repo_owner
    assert repository["name"] == @repo_name
    assert repository["url"] == @repo_url
    assert repository["synced_at"] |> from_iso8601!()

    # and there are three stargazers watching the repository
    assert %{"data" => [stargazer_1, stargazer_2, stargazer_3]} =
             conn
             |> get("/api/repositories/#{repository["id"]}/stargazers")
             |> json_response(200)

    # verify all stargazers are returned
    assert stargazer_1["github_user_id"] == @stargazer_1_id
    assert stargazer_1["url"] == @stargazer_1_url
    assert stargazer_1["name"] == @stargazer_1_name
    assert stargazer_1["starred_at"] == @stargazer_1_starred_at |> to_iso8601()
    assert stargazer_1["is_deleted"] == false

    assert stargazer_2["github_user_id"] == @stargazer_2_id
    assert stargazer_2["url"] == @stargazer_2_url
    assert stargazer_2["name"] == @stargazer_2_name
    assert stargazer_2["starred_at"] == @stargazer_2_starred_at |> to_iso8601()
    assert stargazer_2["is_deleted"] == false

    assert stargazer_3["github_user_id"] == @stargazer_3_id
    assert stargazer_3["url"] == @stargazer_3_url
    assert stargazer_3["name"] == @stargazer_3_name
    assert stargazer_3["starred_at"] == @stargazer_3_starred_at |> to_iso8601()
    assert stargazer_3["is_deleted"] == false

    # specifying a date range excludes the third stargazer
    assert %{"data" => [stargazer_1, stargazer_2]} =
             conn
             |> get(
               "/api/repositories/#{repository["id"]}/stargazers",
               start_date: @stargazer_1_starred_at |> to_date() |> Date.to_string(),
               end_date: @stargazer_2_starred_at |> to_date() |> Date.to_string()
             )
             |> json_response(200)

    # verify only the first two stargazers are returned
    assert stargazer_1["github_user_id"] == @stargazer_1_id
    assert stargazer_1["url"] == @stargazer_1_url
    assert stargazer_1["name"] == @stargazer_1_name
    assert stargazer_1["starred_at"] == @stargazer_1_starred_at |> to_iso8601()
    assert stargazer_1["is_deleted"] == false

    assert stargazer_2["github_user_id"] == @stargazer_2_id
    assert stargazer_2["url"] == @stargazer_2_url
    assert stargazer_2["name"] == @stargazer_2_name
    assert stargazer_2["starred_at"] == @stargazer_2_starred_at |> to_iso8601()
    assert stargazer_2["is_deleted"] == false

    # all stargazers have now unstarred the repository </3 
    expect(GitHubMock, :get_stargazers, fn @repo_owner, @repo_name ->
      {:ok, []}
    end)

    # resync all stargazers for the repository
    repository["id"]
    |> GitHub.get_repository!()
    |> GitHub.sync_stargazers()

    # former stargazers still exist in Gazerbeam
    assert %{"data" => [stargazer_1, stargazer_2, stargazer_3]} =
             conn
             |> get("/api/repositories/#{repository["id"]}/stargazers")
             |> json_response(200)

    # but these stargazers are marked as soft-deleted
    assert stargazer_1["github_user_id"] == @stargazer_1_id
    assert stargazer_1["url"] == @stargazer_1_url
    assert stargazer_1["name"] == @stargazer_1_name
    assert stargazer_1["starred_at"] == @stargazer_1_starred_at |> to_iso8601()
    assert stargazer_1["is_deleted"] == true

    assert stargazer_2["github_user_id"] == @stargazer_2_id
    assert stargazer_2["url"] == @stargazer_2_url
    assert stargazer_2["name"] == @stargazer_2_name
    assert stargazer_2["starred_at"] == @stargazer_2_starred_at |> to_iso8601()
    assert stargazer_2["is_deleted"] == true

    assert stargazer_3["github_user_id"] == @stargazer_3_id
    assert stargazer_3["url"] == @stargazer_3_url
    assert stargazer_3["name"] == @stargazer_3_name
    assert stargazer_3["starred_at"] == @stargazer_3_starred_at |> to_iso8601()
    assert stargazer_3["is_deleted"] == true
  end

  test "Gazerbeam Error Handling", %{conn: conn} do
    # GitHub API returns a 404
    expect(GitHubMock, :get_repository, fn @repo_owner, @repo_name ->
      {:error, %HTTPoison.Response{status_code: 404}}
    end)

    # cannot track a repository that does not exist in GitHub
    assert %{"errors" => %{"detail" => "Not Found"}} ==
             conn
             |> post("/api/repositories", %{owner: @repo_owner, name: @repo_name})
             |> json_response(404)
  end
end
