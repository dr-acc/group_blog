defmodule Blog.Repo.Migrations.CoverImage do
  use Ecto.Migration

  def change do
    create table(:cover_images) do
      add :url, :text
      add :post_id, references(:posts, on_delete: :delete_all), null: false
    end

    create index(:cover_images, [:post_id])
  end
end
