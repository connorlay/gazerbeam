defmodule GazerbeamWeb.Router do
  use GazerbeamWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GazerbeamWeb do
    pipe_through :api

    resources "/repositories", RepositoryController, only: [:index, :create] do
      resources "/stargazers", StargazerController, only: [:index]
    end
  end
end
