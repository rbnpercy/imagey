defmodule ImageyWeb.PhotoController do
  use ImageyWeb, :controller

  alias Imagey.Images
  alias Imagey.Images.Photo

  def index(conn, _params) do
    photos = Images.list_photos()
    render(conn, "index.html", photos: photos)
  end

  def new(conn, _params) do
    changeset = Images.change_photo(%Photo{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"photo" => photo_params}) do
    case Images.create_photo(photo_params) do
      {:ok, photo} ->
        conn
        |> put_flash(:info, "Photo created successfully.")
        |> redirect(to: photo_path(conn, :show, photo))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    photo = Images.get_photo!(id)
    render(conn, "show.html", photo: photo)
  end

  def edit(conn, %{"id" => id}) do
    photo = Images.get_photo!(id)
    changeset = Images.change_photo(photo)
    render(conn, "edit.html", photo: photo, changeset: changeset)
  end

  def update(conn, %{"id" => id, "photo" => photo_params}) do
    photo = Images.get_photo!(id)

    case Images.update_photo(photo, photo_params) do
      {:ok, photo} ->
        conn
        |> put_flash(:info, "Photo updated successfully.")
        |> redirect(to: photo_path(conn, :show, photo))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", photo: photo, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    photo = Images.get_photo!(id)
    {:ok, _photo} = Images.delete_photo(photo)

    conn
    |> put_flash(:info, "Photo deleted successfully.")
    |> redirect(to: photo_path(conn, :index))
  end
end
