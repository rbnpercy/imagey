defmodule Imagey.Images.Photo do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "photos" do
    field :image, :string

    belongs_to :album, Imagey.Images.Album

    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:album_id, :image])
    |> validate_required([:image])
  end
end
