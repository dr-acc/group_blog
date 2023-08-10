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
  @invalid_attrs %{content: nil, title: nil, tag_ids: []}

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Posts"
    end

    test "search posts", %{conn: conn} do
      user = user_fixture()
      found = post_fixture(title: "my_awesome_title", visibility: true, user_id: user.id)
      not_found = post_fixture(title: "boring_title", visibility: true, user_id: user.id)

      conn = get(conn, ~p"/posts", title: "my_awesome_title")

      assert html_response(conn, 200) =~ found.title
      refute html_response(conn, 200) =~ not_found.title
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/posts/new")

      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      post_attr =
        %{title: "awesome title", content: "some content", visibility: true, user_id: user.id}

      conn = post(conn, ~p"/posts", post: post_attr)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "creating post that contains tags", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      tag = tag_fixture()

      post_attrs = %{
        content: "some content",
        title: "some title",
        visibility: true,
        user_id: user.id,
        tag_ids: [tag.id]
      }

      conn = post(conn, ~p"/posts", post: post_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"
      assert Posts.get_post!(id).tags == [tag]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user) |> post(~p"/posts", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end

    test "create post with cover image", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      create_attrs = %{
        content: "some content",
        title: "some title",
        visibility: true,
        published_on: DateTime.utc_now(),
        user_id: user.id,
        cover_image: %{
          url: "https://www.example.com/image.png"
        }
      }

      conn = post(conn, ~p"/posts", post: create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      post = Posts.get_post!(id)
      # post was created with cover image
      assert %Blog.Posts.CoverImage{url: "https://www.example.com/image.png"} = post.cover_image
      # post cover image is displayed on show page
      # assert %{id: id} = redirected_params(conn)
      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "https://www.example.com/image.png"
    end

  end

  describe "edit post" do
    # post: post
    test "renders form for editing chosen post", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)
      conn = log_in_user(conn, user)

      conn = get(conn, ~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit Post"
    end

    test "user can not edit other user's post", %{conn: conn} do
      user = user_fixture()
      other_user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)
      conn = conn |> log_in_user(other_user) |> get(~p"/posts/#{post}/edit")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "You can only edit or delete your own posts."

      assert redirected_to(conn) == ~p"/posts/#{post}"
    end
  end

  describe "update post" do
    test "redirects when data is valid", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)
      conn = log_in_user(conn, user)

      conn = put(conn, ~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "update posts should also update tags", %{conn: conn} do
      user = user_fixture()
      tag = tag_fixture()
      new_tag = tag_fixture(name: "tag2")
      post = post_fixture(visibility: true, user_id: user.id, tag_ids: [tag.id])

      conn = log_in_user(conn, user)

      conn =
        put(conn, ~p"/posts/#{post}",
          post: %{
            content: "some updated content",
            visibility: true,
            title: "some updated title",
            tag_ids: [new_tag.id]
          }
        )

      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ new_tag.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(visibility: true, user_id: user.id)

      conn = conn |> log_in_user(user) |> put(~p"/posts/#{post}", post: @invalid_attrs)
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
