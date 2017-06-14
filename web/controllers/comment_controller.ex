defmodule Nested.CommentController do
  use Nested.Web, :controller

  alias Nested.Comment

  def index(conn, %{"post_id" => post_id}) do
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
end
