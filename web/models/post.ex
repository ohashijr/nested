defmodule Nested.Post do
  use Nested.Web, :model

  schema "posts" do
    field :title, :string
    field :body, :string
    has_many :comments, Nested.Comment
    belongs_to :user, Nested.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body, :user_id])
    |> validate_required([:title, :body])
  end
end
