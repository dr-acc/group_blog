defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :visibility, :boolean
    field :title, :string
    field :published_on, :utc_datetime
    has_many :comments, Blog.Comments.Comment
    belongs_to :user, Blog.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :visibility, :content, :published_on, :user_id])
    |> validate_required([:title, :visibility, :content, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
