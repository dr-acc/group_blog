defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :visibility, :boolean
    field :title, :string
    field :published_on, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :visibility, :content, :published_on])
    |> validate_required([:title, :visibility, :content])
  end
end
