defmodule Gazerbeam.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add(:github_id, :integer, null: false)
      add(:url, :string, null: false)
      add(:owner, :string, null: false)
      add(:name, :string, null: false)
      add(:synced_at, :naive_datetime)

      timestamps()
    end

    create(unique_index(:repositories, [:github_id]))
    create(unique_index(:repositories, [:url]))
    create(unique_index(:repositories, [:owner, :name]))
  end
end
