defmodule GazerbeamWeb.StargazerController do
  use GazerbeamWeb, :controller

  alias Gazerbeam.GitHub

  action_fallback GazerbeamWeb.FallbackController

  def index(conn, %{
        "repository_id" => repository_id,
        "start_date" => start_date,
        "end_date" => end_date
      }) do
    with {:ok, start_date} <- parse_date_to_naive(start_date),
         {:ok, end_date} <- parse_date_to_naive(end_date) do
      stargazers = GitHub.list_stargazers(repository_id, start_date, end_date)
      render(conn, "index.json", stargazers: stargazers)
    end
  end

  def index(conn, %{"repository_id" => repository_id}) do
    stargazers = GitHub.list_stargazers(repository_id)
    render(conn, "index.json", stargazers: stargazers)
  end

  defp parse_date_to_naive(string) do
    try do
      date =
        string
        |> Date.from_iso8601!()
        |> NaiveDateTime.new!(Time.new!(0, 0, 0))

      {:ok, date}
    rescue
      _ ->
        {:error, :malformed_date}
    end
  end
end
