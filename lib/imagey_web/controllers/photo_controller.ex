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

  def store(conn, file, album) do
    case Images.create_photo(%{album_id: album, image: file}) do
      {:ok, photo} ->

        header = [{"Content-Type", "application/json"}]
        body = "{\"height\": \"250\", \"width\": \"250\", \"bucket\": \"#{album_id}\" }"
        HTTPotion.post("https://AWS_WORKER/2/projects/{Project ID}/tasks", [body: body, headers: header])

        conn
        |> put_flash(:info, "Photos created successfully.")
        |> redirect(to: album_path(conn, :show, album))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"photo" => %{"image" => image_params} = photo_params}) do
      album_id = photo_params["album_id"]

      ExAws.S3.put_bucket("#{album_id}", "eu-west-2")
      |> ExAws.request()

      Enum.map(image_params, fn(img) ->
        album = album_id
        ext = Path.extname(img.filename)
        u = Ecto.UUID.generate
        flnm = "#{u}#{ext}"

        {:ok, file_binary} = File.read(img.path)

        s3_bucket = album
        {:ok, _} =
          ExAws.S3.put_object(s3_bucket, flnm, file_binary)
          |> ExAws.request()

        store(conn, flnm, album)
      end)
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
