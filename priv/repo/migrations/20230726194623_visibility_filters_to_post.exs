defmodule Blog.Repo.Migrations.VisibilityFiltersToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :subtitle
      add :visibility, :boolean, default: true
      add :published_on, :utc_datetime
    end
    create unique_index(:posts, [:title])
  end
end
