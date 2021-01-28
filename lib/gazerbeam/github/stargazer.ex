defmodule Gazerbeam.GitHub.Stargazer do
  @moduledoc """
  GitHub Stargazer who has starred a given Repository
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "stargazers" do
    field :github_user_id, :integer, null: false
    field :name, :string, null: false
    field :url, :string, null: false
    field :repository_id, :id, null: false
    field :starred_at, :naive_datetime, null: false
    field :is_deleted, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(stargazer, attrs) do
    stargazer
    |> cast(attrs, [:github_user_id, :starred_at, :name, :url, :is_deleted])
    |> validate_required([:github_user_id, :starred_at, :name, :url])
    |> unique_constraint([:github_user_id, :repository_id])
  end
end
