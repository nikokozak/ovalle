defmodule Ovalle.FileUtils do
  import Path, only: [join: 2, join: 1]
  @moduledoc """
  Provides utilities for working with files.
  """

  def base_dir, do: Application.fetch_env!(:ovalle, :archive_dir)

  def create_collection(collection_name) do
    target = join(base_dir(), collection_name)
    if File.exists?(target), do: {:error, :eexist}, else: File.mkdir(target)
  end

  def delete_collection(collection_name) do
    target = join(base_dir(), collection_name)
    if File.exists?(target), do: File.rm_rf(target), else: :ok
  end

  def create_set(collection_name, set_name) do
    target = join([base_dir(), collection_name, set_name])
    if File.exists?(target), do: {:error, :eexist}, else: File.mkdir(target)
  end

  def delete_set(collection_name, set_name) do
    target = join([base_dir(), collection_name, set_name])
    if File.exists?(target), do: File.rm_rf(target), else: :ok
  end

end
