defmodule Nested.CommentController do
  use Nested.Web, :controller

  alias Nested.{User, Comment, Post}
  plug PolicyWonk.LoadResource, [:post] when action in [:index, :show, :edit, :update, :delete]
  plug PolicyWonk.Enforce, :post_owner when action in [:index, :show, :edit, :update, :delete]

  def index(conn, %{"post_id" => post_id}) do

    #query = from c in Comment,
    #        join: p in Post, where: c.post_id == p.id
    #        and p.id == ^post_id and p.user_id == ^conn.assigns.current_user.id

    #comments = Repo.all(query)
    #render(conn, "index.html", post_id: post_id, comments: comments)
    query = from p in Comment, where: p.post_id == ^post_id
    comments = Repo.all(query)
    render(conn, "index.html", post_id: post_id, comments: comments)
  end

  def new(conn, %{"post_id" => post_id}) do
    changeset = Comment.changeset(%Comment{})
    render(conn, "new.html", post_id: post_id, changeset: changeset)
  end

  def create(conn, %{"post_id" => post_id, "comment" => comment_params}) do
    changeset = Comment.changeset(%Comment{}, Map.put(comment_params, "post_id", post_id))

    case Repo.insert(changeset) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: post_comment_path(conn, :index, post_id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "post_id" => post_id}) do
    comment = Repo.get!(Comment, id)
    render(conn, "show.html", post_id: post_id, comment: comment)
  end

  def edit(conn, %{"id" => id, "post_id" => post_id}) do
    comment = Repo.get!(Comment, id)
    changeset = Comment.changeset(comment)
    render(conn, "edit.html", post_id: post_id, comment: comment, changeset: changeset)
  end

  def update(conn, %{"post_id" => post_id, "id" => id, "comment" => comment_params}) do
    comment = Repo.get!(Comment, id)
    changeset = Comment.changeset(comment, comment_params)

    case Repo.update(changeset) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: post_comment_path(conn, :show, post_id, comment))
      {:error, changeset} ->
        render(conn, "edit.html", comment: comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "post_id" => post_id}) do
    comment = Repo.get!(Comment, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: post_comment_path(conn, :index, post_id))
  end

  def policy(assigns, :post_owner) do
    case {assigns[:current_user], assigns[:post]} do
      {%User{id: user_id}, post=%Post{}} ->
        case post.user_id do
          ^user_id -> :ok
          _ -> :not_found
        end
      _ -> :not_found
    end
  end

  def load_resource(_conn, :post, %{"post_id" => id}) do
    case Repo.get(Post, id) do
      nil -> :not_found
      post -> {:ok, :post, post}
    end
  end

  def policy_error(conn, :not_found) do
    Nested.ErrorHandlers.resource_not_found(conn, :not_found)
  end
end
