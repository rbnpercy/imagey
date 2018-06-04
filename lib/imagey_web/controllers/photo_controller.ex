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

  def upload(photos) do
    Enum.map(photos, fn(upload) ->
      ext = Path.extname(upload.filename)
      u = Ecto.UUID.generate
      flnm = "#{u}#{ext}"

      {:ok, file_binary} = File.read(upload.path)

      s3_bucket = "imagey-elixir"
      {:ok, _} =
        ExAws.S3.put_object(s3_bucket, flnm, file_binary)
        |> ExAws.request()

      IO.puts flnm
    end)

  end

  def create(conn, %{"photo" => %{"image" => image_params} = photo_params}) do

    upload(image_params)

      # for img <- u do
      #
      # end

      # IO.inspect photo_params

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

  defp multisend_to_s3 do
    upload_file = fn {src_path, dest_path} ->
      ExAws.S3.put_object("imagey-elixir", dest_path, File.read!(src_path))
      |> ExAws.request!
    end

    paths = %{"path/to/src0" => "path/to/dest0", "path/to/src1" => "path/to/dest1"}

    paths
    |> Task.async_stream(upload_file, max_concurrency: 20)
    |> Stream.run

  end
end
