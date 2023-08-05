defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  alias Blog.Posts

  import Blog.AccountsFixtures
  import Blog.CommentsFixtures
  import Blog.PostsFixtures
  import Blog.TagsFixtures


  @create_attrs %{content: "some content", visibility: true, title: "some title"}
  @update_attrs %{
    content: "some updated content",
    visibility: true,
    title: "some updated title"
  }
  @invalid_attrs %{content: nil, title: nil}

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Posts"
    end

    test "search posts", %{conn: conn} do
      user = user_fixture()
      found = post_fixture(title: "my_awesome_title", visibility: true, user_id: user.id)
      not_found = post_fixture(title: "boring_title", visibility: true,  user_id: user.id)

      conn = get(conn, ~p"/posts", title: "my_awesome_title")
      assert html_response(conn, 200) =~ found.title
      # assert html_response(conn, 200) =~ found.visibility
      refute html_response(conn, 200) =~ not_found.title
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      user = user_fixture()
      conn = conn
          |> log_in_user(user)
          |> get(~p"/posts/new")

      assert html_response(conn, 200) =~ "New Post"
    end
  end
  test "show pages contains tags"


  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      post_attr =
        %{title: "awesome title",
        content: "some content",
        visibility: true,
        user_id: user.id}

      conn = post(conn, ~p"/posts", post: post_attr)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user) |> post(~p"/posts", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "edit post" do
    test "renders form for editing chosen post", %{conn: conn} do #post: post
      user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)
      conn = log_in_user(conn, user)

      conn = get(conn, ~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "update post" do
    test "redirects when data is valid", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)
      conn = log_in_user(conn,user)

      conn = put(conn, ~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "update posts should preserve tags "

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()
      # post_fixture(visibility: true, user_id: user.id)
      conn = log_in_user(conn, user)

      conn = put(conn, ~p"/posts/", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "delete post" do
    test "deletes chosen post", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)
      conn = log_in_user(conn, user)

      conn = delete(conn, ~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts"

      assert_error_sent(404, fn ->
        get(conn, ~p"/posts/#{post}")
      end)
    end
  end

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end
end
