defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}, _tags \\ []) do
    tags = attrs[:tags] || []
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        visibility: Enum.random([true, false]),
        title: "some title",
        published_on: DateTime.utc_now()
      })
      |> Blog.Posts.create_post(tags)

    post
  end
end
