defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures
    @invalid_attrs %{content: nil, visibility: nil, title: nil, published_on: nil}

    test "posts sorted most recent on top" do
      first_post =
        post_fixture(
          title: "First post",
          published_on: ~U[2023-07-25 18:14:15Z],
          visibility: true
        )

      second_post =
        post_fixture(
          title: "Second post",
          published_on: ~U[2023-07-26 18:14:15Z],
          visibility: true
        )

      third_post =
        post_fixture(
          title: "Third post",
          published_on: ~U[2023-07-27 18:14:15Z],
          visibility: true
        )

      assert Posts.list_posts() |> Enum.map(fn %{id: id} -> id end) == [
               third_post.id,
               second_post.id,
               first_post.id
             ]

      # IO.inspect(all_post, label: "********* Alena's inspect *********")
    end

    test "posts with visibility true display but not false" do
      not_visible_post = post_fixture(title: "First post", visibility: false)

      visible_post = post_fixture(title: "Second post", visibility: true)

      assert Posts.list_posts() == [visible_post]

    end

    test "search_posts/1 returns filtered posts" do
      post = post_fixture(title: "title")
      assert Posts.search_posts("Title") == [post]
      assert Posts.search_posts("itl") == [post]
      assert Posts.search_posts("tle") == [post]
      assert Posts.search_posts("") == [post]
      assert Posts.search_posts("luis") == []
      IO.inspect(post)
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      IO.inspect(post)
      assert Posts.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{content: "some content", visibility: true, title: "some title"}

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.content == "some content"
      assert post.visibility == true
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()

      update_attrs = %{
        content: "some updated content",
        visibility: false,
        title: "some updated title"
      }

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.content == "some updated content"
      assert post.visibility == false
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end

    #test that posts with future dates don't show yet
    test "posts published in past display; future posts do not" do
      _future_post =
        post_fixture(
          title: "Future post",
          visibility: true,
          published_on: DateTime.add(DateTime.utc_now, 1, :hour)
        )

      past_post =
        post_fixture(
          title: "Past post",
          visibility: true,
          published_on: DateTime.utc_now()
        )
      assert Posts.list_posts() == [past_post]
    end
  end
end
