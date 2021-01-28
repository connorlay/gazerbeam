defmodule Gazerbeam.GitHub.Repository do
  @moduledoc """
  GitHub repository tracked by Gazerbeam
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Gazerbeam.GitHub.Stargazer

  schema "repositories" do
    field :github_id, :integer, null: false
    field :name, :string, null: false
    field :owner, :string, null: false
    field :url, :string, null: false
    field :synced_at, :naive_datetime

    has_many :stargazers, Stargazer

    timestamps()
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [:github_id, :url, :owner, :name, :synced_at])
    |> validate_required([:github_id, :url, :owner, :name])
    |> unique_constraint(:github_id)
    |> unique_constraint(:url)
    |> unique_constraint([:owner, :name])
  end
end
