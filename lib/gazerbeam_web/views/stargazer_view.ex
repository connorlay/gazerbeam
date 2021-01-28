defmodule GazerbeamWeb.StargazerView do
  use GazerbeamWeb, :view
  alias GazerbeamWeb.StargazerView

  def render("index.json", %{stargazers: stargazers}) do
    %{data: render_many(stargazers, StargazerView, "stargazer.json")}
  end

  def render("show.json", %{stargazer: stargazer}) do
    %{data: render_one(stargazer, StargazerView, "stargazer.json")}
  end

  def render("stargazer.json", %{stargazer: stargazer}) do
    %{
      id: stargazer.id,
      github_user_id: stargazer.github_user_id,
      starred_at: stargazer.starred_at,
      name: stargazer.name,
      url: stargazer.url,
      is_deleted: stargazer.is_deleted
    }
  end
end
