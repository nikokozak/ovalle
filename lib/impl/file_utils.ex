defmodule Ovalle.FileUtils do
  import Path, only: [join: 2, join: 1]
  @moduledoc """
  Provides utilities for working with files.
  """

  def base_dir, do: Application.fetch_env!(:ovalle, :archive_dir)

  defp collection_path(collection_name), do: join(base_dir(), collection_name)
  defp set_path(collection_name, set_name), do: join([base_dir(), collection_name, set_name])

  defp collection_exists?(collection_name), do: File.exists?(join(base_dir(), collection_name))
  defp set_exists?(collection_name, set_name), do: File.exists?(join([base_dir(), collection_name, set_name]))

  def create_collection(collection_name) do
    cond do
      collection_exists?(collection_name) -> {:error, :eexist}
      true -> File.mkdir collection_path(collection_name)
    end
  end

  def delete_collection(collection_name) do
    cond do
      collection_exists?(collection_name) -> File.rm_rf collection_path(collection_name)
      true -> {:ok, []}
    end
  end

  def create_set(collection_name, set_name) do
    cond do
      not collection_exists?(collection_name) -> {:error, :no_collection}
      set_exists?(collection_name, set_name) -> {:error, :eexist}
      true -> File.mkdir set_path(collection_name, set_name)
    end
  end

  def delete_set(collection_name, set_name) do
    cond do
      set_exists?(collection_name, set_name) -> File.rm_rf set_path(collection_name, set_name)
      true -> {:ok, []}
    end
  end

end
