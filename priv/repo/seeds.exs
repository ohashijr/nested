# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Nested.Repo.insert!(%Nested.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Nested.Repo.delete_all Nested.User

Nested.User.changeset(%Nested.User{}, %{name: "Orlando Ohashi", email: "ohashijr@gmail.com", password: "ohashi", password_confirmation: "ohashi"})
|> Nested.Repo.insert!
