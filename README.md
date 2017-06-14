# Nested

```elixir
mix ecto.create
```

```elixir
mix phoenix.gen.html Post posts title body:text
```

* web/router.ex
```elixir
defmodule Nested.Router do
  use Nested.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Nested do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/posts", PostController # ADD
  end
end
```

* migrar a tabela posts
```elixir
mix ecto.migrate
```

* testar o CRUD do posts
```elixir
mix phoenix.server
```

* gerando o comment
```elixir
mix phoenix.gen.html Comment comments title body:text post_id:references:posts
```

* associar os models, models/post.ex
```elixir
defmodule Nested.Post do
  use Nested.Web, :model

  schema "posts" do
    field :title, :string
    field :body, :string
    has_many :comments, Nested.Comment

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
  end
end
```

* web/router.ex
```elixir
resources "/posts", PostController do
  resources "/comments", CommentController
end
```

* ajustar o controller/comment_controller.ex
```elixir
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
```

* ajustar os paths
** templates/commet/edit.html.eex
```elixir
<h2>Edit comment</h2>

<%= render "form.html", changeset: @changeset,
                        action: post_comment_path(@conn, :update, @post_id, @comment) %>

<%= link "Back", to: post_comment_path(@conn, :index, @post_id) %>
```

** templates/commet/index.html.eex
```elixir
<h2>Listing comments</h2>

<table class="table">
  <thead>
    <tr>
      <th>Title</th>
      <th>Body</th>
      <th>Post</th>

      <th></th>
    </tr>
  </thead>
  <tbody>
<%= for comment <- @comments do %>
    <tr>
      <td><%= comment.title %></td>
      <td><%= comment.body %></td>
      <td><%= comment.post_id %></td>

      <td class="text-right">
        <%= link "Show", to: post_comment_path(@conn, :show, @post_id, comment), class: "btn btn-default btn-xs" %>
        <%= link "Edit", to: post_comment_path(@conn, :edit, @post_id, comment), class: "btn btn-default btn-xs" %>
        <%= link "Delete", to: post_comment_path(@conn, :delete, @post_id, comment), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %>
      </td>
    </tr>
<% end %>
  </tbody>
</table>

<%= link "New comment", to: post_comment_path(@conn, :new, @post_id) %>
```

** templates/commet/new.html.eex
```elixir
<h2>New comment</h2>

<%= render "form.html", changeset: @changeset,
                        action: post_comment_path(@conn, :create, @post_id) %>

<%= link "Back", to: post_comment_path(@conn, :index, @post_id) %>
```

** templates/commet/show.html.eex
```elixir
<h2>Show comment</h2>

<ul>

  <li>
    <strong>Title:</strong>
    <%= @comment.title %>
  </li>

  <li>
    <strong>Body:</strong>
    <%= @comment.body %>
  </li>

  <li>
    <strong>Post:</strong>
    <%= @comment.post_id %>
  </li>

</ul>

<%= link "Edit", to: post_comment_path(@conn, :edit, @post_id, @comment) %>
<%= link "Back", to: post_comment_path(@conn, :index, @post_id) %>
```

* migrar a tabela comments
```elixir
mix ecto.migrate
```

* ajustar o templates/post/index.html.eex
```elixir
<h2>Listing posts</h2>

<table class="table">
  <thead>
    <tr>
      <th>Title</th>
      <th>Body</th>
      <th></th>
    </tr>
  </thead>
  <tbody>
<%= for post <- @posts do %>
    <tr>
      <td><%= post.title %></td>
      <td><%= post.body %></td>

      <td class="text-right">
        <%= link "Show", to: post_comment_path(@conn, :index, post), class: "btn btn-default btn-xs" %>
        <%= link "Edit", to: post_path(@conn, :edit, post), class: "btn btn-default btn-xs" %>
        <%= link "Delete", to: post_path(@conn, :delete, post), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %>
      </td>
    </tr>
<% end %>
  </tbody>
</table>

<%= link "New post", to: post_path(@conn, :new) %>
```

```elixir
```

```elixir
```

```elixir
```
