defmodule Imagey.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :image, :string
      add :album_id, references(:albums, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:photos, [:album_id])
  end
end
