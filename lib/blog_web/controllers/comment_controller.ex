defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Comments

  ###[:create, :update, :delete]

  def create(conn, _params) do
    render(conn, :create )
  end

  def update(conn, _params) do
    render(conn, :update )
  end

  def delete(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    {:ok, comment} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: ~p"/posts")
  end
end
