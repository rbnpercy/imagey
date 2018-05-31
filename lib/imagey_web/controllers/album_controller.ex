defmodule ImageyWeb.AlbumController do
  use ImageyWeb, :controller

  alias Imagey.Images
  alias Imagey.Images.Album

  def index(conn, _params) do
    albums = Images.list_albums()
    render(conn, "index.html", albums: albums)
  end

  def new(conn, _params) do
    changeset = Images.change_album(%Album{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"album" => album_params}) do
    case Images.create_album(album_params) do
      {:ok, album} ->
        conn
        |> put_flash(:info, "Album created successfully.")
        |> redirect(to: album_path(conn, :show, album))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    album = Images.get_album!(id)
    render(conn, "show.html", album: album)
  end

  def edit(conn, %{"id" => id}) do
    album = Images.get_album!(id)
    changeset = Images.change_album(album)
    render(conn, "edit.html", album: album, changeset: changeset)
  end

  def update(conn, %{"id" => id, "album" => album_params}) do
    album = Images.get_album!(id)

    case Images.update_album(album, album_params) do
      {:ok, album} ->
        conn
        |> put_flash(:info, "Album updated successfully.")
        |> redirect(to: album_path(conn, :show, album))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", album: album, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    album = Images.get_album!(id)
    {:ok, _album} = Images.delete_album(album)

    conn
    |> put_flash(:info, "Album deleted successfully.")
    |> redirect(to: album_path(conn, :index))
  end
end
