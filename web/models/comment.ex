defmodule Nested.Comment do
  use Nested.Web, :model

  schema "comments" do
    field :title, :string
    field :body, :string
    belongs_to :post, Nested.Post

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body, :post_id])
    |> validate_required([:title, :body, :post_id])
  end
end
