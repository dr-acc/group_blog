# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
# Blog.Repo.insert!(%Blog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# 1..100
# |> Enum.each(fn each ->
#   Blog.Repo.insert!(%Blog.Posts{%{title: "Sample title#{each}",
#   subtitle: "Subtitle #{each}",
#   content: " Enum.reduce Enum.reduce([1, 2, 3, 4], fn x, acc -> x * acc end)"}}
#   )
# end)
user =
  Blog.Repo.insert!(%Blog.Accounts.User{
    username: "im_blx",
    email: "thisisnotmyemail@gmail.com",
    password: "password123",
    hashed_password: "password123"
  })

1..10
|> Enum.map(fn each ->
  Blog.Repo.insert!(%Blog.Posts.Post{
    title: "Sample title #{each}",
    content: "Blog.Repo.insert!(%Blog.Posts.Post{} #{each}",
    published_on: DateTime.truncate(DateTime.utc_now(), :second),
    visibility: true,
    user_id: user.id
  })
end)
