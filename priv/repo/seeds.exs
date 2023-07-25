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
1..10
|> Enum.map(fn each ->
Blog.Repo.insert!(%Blog.Posts.Post{title: "Sample title #{each}", subtitle: "subtitle #{each}",
content: "Blog.Repo.insert!(%Blog.Posts.Post{} #{each}"})
end)
