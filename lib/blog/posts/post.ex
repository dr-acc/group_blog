defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :visibility, :boolean
    field :title, :string
    field :published_on, :utc_datetime

    belongs_to :user, Blog.Accounts.User
    has_many :comments, Blog.Comments.Comment
    many_to_many :tags, Blog.Tags.Tag, join_through: "posts_tags"

    timestamps()
  end

  @doc false
  def changeset(post, attrs, tags \\ []) do
    post
    |> cast(attrs, [:title, :visibility, :content, :published_on, :user_id])
    |> validate_required([:title, :visibility, :content, :user_id])
    |> foreign_key_constraint(:user_id)
    |> put_assoc(:tags, tags)
  end
end
