defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts
  alias Blog.Comments

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures
    import Blog.CommentsFixtures
    import Blog.AccountsFixtures
    import Blog.TagsFixtures
    @invalid_attrs %{content: nil, visibility: nil, title: nil, published_on: nil}

    test "posts sorted most recent on top" do
      user = user_fixture()

      first_post =
        post_fixture(
          title: "First post",
          published_on: ~U[2023-07-25 18:14:15Z],
          visibility: true,
          user_id: user.id
        )

      second_post =
        post_fixture(
          title: "Second post",
          published_on: ~U[2023-07-26 18:14:15Z],
          visibility: true,
          user_id: user.id
        )

      third_post =
        post_fixture(
          title: "Third post",
          published_on: ~U[2023-07-27 18:14:15Z],
          visibility: true,
          user_id: user.id
        )

      assert Posts.list_posts() |> Enum.map(fn %{id: id} -> id end) == [
               third_post.id,
               second_post.id,
               first_post.id
             ]
    end

    test "posts with visibility true display but not false" do
      user = user_fixture()
      not_visible_post = post_fixture(title: "First post", visibility: false, user_id: user.id)
      visible_post = post_fixture(title: "Second post", visibility: true, user_id: user.id)

      assert Posts.list_posts() == [visible_post]
    end

    test "search_posts/1 returns filtered posts" do
      user = user_fixture()
      post = post_fixture(title: "title", user_id: user.id)
      assert Posts.search_posts("Title") == [post]
      assert Posts.search_posts("itl") == [post]
      assert Posts.search_posts("tle") == [post]
      assert Posts.search_posts("") == [post]
      assert Posts.search_posts("luis") == []
    end

    test "list_posts/0 returns all posts" do
      user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)

      fetched_post = Posts.list_posts() |> Enum.at(0)

      assert fetched_post.id == post.id
    end

    test "get_post!/1 returns the post with given id" do
      user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)
      fetched_post = Posts.get_post!(post.id)

      assert fetched_post.id == post.id
      assert fetched_post.title == post.title
      assert fetched_post.published_on == post.published_on
      # Examples for posterity:
      # assert Posts.get_post!(post.id).title == post.title
      # assert Posts.get_post!(post.id).published_on == post.published_on
    end

    test "get_post!/1 returns the post with comments" do
      user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)

      comment1 = comment_fixture(post_id: post.id, user_id: user.id)
      comment2 = comment_fixture(post_id: post.id, user_id: user.id)

      fetched_post = Posts.get_post!(post.id)
      assert fetched_post.comments == [comment1, comment2]
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()

      valid_attrs = %{
        content: "some content",
        visibility: true,
        title: "some title",
        user_id: user.id
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.content == "some content"
      assert post.visibility == true
      assert post.title == "some title"
      assert post.user_id == user.id
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "create_post/1 with tags" do
      user = user_fixture()
      tag = tag_fixture()

      valid_attrs = %{
        content: "some content",
        visibility: true,
        title: "some title",
        user_id: user.id
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs, [tag])
      assert post.tags == [tag]
    end

    test "create_post/1 with cover image from url" do
      user = user_fixture()

      valid_attrs = %{
        content: "some content",
        title: "some title",
        cover_image: %{
          url: "https://www.example.com/image.png"
        },
        visibility: true,
        published_on: DateTime.utc_now(),
        user_id: user.id
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      # assert %CoverImage{url: "https://www.example.com/image.png"} = Repo.preload(post, :cover_image).cover_image
    end

    test "update_post/2 with tags" do
      user = user_fixture()
      tag = tag_fixture()
      other_tag = tag_fixture(name: "other name")

      valid_attrs = %{
        content: "some content",
        visibility: true,
        title: "some title",
        user_id: user.id
      }

      post = post_fixture(valid_attrs)

      assert {:ok, %Post{} = updated_post} = Posts.update_post(post, valid_attrs, [other_tag])
      assert updated_post.tags == [other_tag]
    end

    test "update_post/2 with valid data updates the post" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      tag = tag_fixture()

      update_attrs = %{
        content: "some updated content",
        visibility: false,
        title: "some updated title",
        user_id: user.id
      }

      update_post = Posts.update_post(post, update_attrs)
      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs, [tag])
      assert post.content == "some updated content"
      assert post.visibility == false
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      fetched_post = Posts.get_post!(post.id)
      assert post.published_on == fetched_post.published_on
      assert post.title == fetched_post.title
      assert post.content == fetched_post.content
    end

    test "delete_post/1 deletes the post" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end

    # test that posts with future dates don't show yet
    test "posts published in past display; future posts do not" do
      user = user_fixture()

      post_fixture(
        title: "Future post",
        visibility: true,
        published_on: DateTime.add(DateTime.utc_now(), 1, :hour),
        user_id: user.id
      )

      past_post =
        post_fixture(
          title: "Past post",
          visibility: true,
          published_on: DateTime.utc_now(),
          user_id: user.id
        )

      assert Posts.list_posts() == [past_post]
    end
  end
end
