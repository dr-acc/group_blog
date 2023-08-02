defmodule Blog.CommentsTest do
  use Blog.DataCase

  alias Blog.Comments

  describe "comments" do
    alias Blog.Comments.Comment

    import Blog.CommentsFixtures
    import Blog.PostsFixtures
    import Blog.AccountsFixtures

    @invalid_attrs %{content: nil}

    test "list_comments/0 returns all comments" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(post_id: post.id, user_id: user.id)
      assert Comments.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(post_id: post.id, user_id: user.id)
      assert Comments.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      # comment = comment_fixture(post_id: post.id, user_id: user.id)
      valid_attrs = %{content: "some content", post_id: post.id, user_id: user.id}

      assert {:ok, %Comment{} = comment} = Comments.create_comment(valid_attrs)
      assert comment.content == "some content"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      assert {:error, %Ecto.Changeset{}} = Comments.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(post_id: post.id, user_id: user.id)

      update_attrs = %{content: "some updated context"}

      assert {:ok, %Comment{} = comment} = Comments.update_comment(comment, update_attrs)
      assert comment.content == "some updated context"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(post_id: post.id, user_id: user.id)

      assert {:error, %Ecto.Changeset{}} = Comments.update_comment(comment, @invalid_attrs)
      assert comment == Comments.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(post_id: post.id, user_id: user.id)

      assert {:ok, %Comment{}} = Comments.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Comments.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(post_id: post.id, user_id: user.id)

      assert %Ecto.Changeset{} = Comments.change_comment(comment)
    end
  end
end
