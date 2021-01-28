defmodule Gazerbeam.Repo.Migrations.CreateStargazers do
  use Ecto.Migration

  def change do
    create table(:stargazers) do
      add(:github_user_id, :integer, null: false)
      add(:starred_at, :naive_datetime, null: false)
      add(:name, :string, null: false)
      add(:url, :string, null: false)
      add(:repository_id, references(:repositories, on_delete: :delete_all), null: false)
      add(:is_deleted, :boolean, default: false)

      timestamps()
    end

    create(index(:stargazers, [:repository_id]))
    create(unique_index(:stargazers, [:github_user_id, :repository_id]))
  end
end
