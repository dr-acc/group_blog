defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false

  alias Blog.Repo
  alias Blog.Comments.Comment
  alias Blog.Posts.Post

  def search_posts(title \\ "") do
    search = "%#{title}%"

    query =
      from(p in Post,
        where: ilike(p.title, ^search),
        # fix visibility
        preload: [:tags, :cover_image]
      )

    Repo.all(query)
  end

  @doc """
  Returns the list of posts.



  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts() do
    today = DateTime.utc_now()

    query =
      Post
      |> where([p], p.visibility)
      |> where([p], p.published_on <= type(^today, :utc_datetime))
      |> order_by([p], desc: p.published_on)
      |> preload([:tags, :cover_image])

    Repo.all(query)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: from(p in Post, preload: [:user, :comments, :tags, :cover_image]) |> Repo.get!(id)
  # def get_post!(id) do
  #   get_comments_query = from c in Comment, order_by: [desc: c.id], preload: :user

  #   get_post_query = from p in Post,  preload: [:user, comments: ^get_comments_query]

  #   Repo.get!(get_post_query, id)
  # end
  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}, tags \\ []) do
    # Post{} == Blog.Posts.Post
    %Post{}
    |> Post.changeset(attrs, tags)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs, tags \\ []) do
    post
    |> Repo.preload(:cover_image)
    |> Post.changeset(attrs, tags)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
