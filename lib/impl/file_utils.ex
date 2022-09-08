defmodule Ovalle.FileUtils do
  import Path, only: [join: 2, join: 1]
  @moduledoc """
  Provides utilities for working with files.
  """

  # TODO: Nested collections
  # TODO: Set -> Original
  # TODO: Sets are hidden sets

  @doc """
  Returns the base directory for the archive, as defined in the config as
  `:archive_dir`.
  """
  @spec base_dir() :: String.t
  def base_dir, do: Application.fetch_env!(:ovalle, :archive_dir)

  ######################################## 

  @spec collection_path(collection_names :: list(String.t)) :: String.t
  defp collection_path(collection_names) when is_list(collection_names), do: join([ base_dir() | collection_names ])
  @spec collection_path(collection_name :: String.t) :: String.t
  defp collection_path(collection_name), do: collection_path([collection_name])

  @spec set_path(collection_name_or_names :: String.t | list(String.t), set_name :: String.t) :: String.t
  defp set_path(collection_name_or_names, set_name), do: join(collection_path(collection_name_or_names), set_name)

  ######################################## 

  @doc """
  Checks whether a collection exists in the archive.
  """
  @spec collection_exists?(collection_name_or_names :: String.t | list(String.t)) :: boolean
  def collection_exists?(collection_name_or_names), do: File.exists?(collection_path(collection_name_or_names))

  @doc """
  Checks whether a set exists in the archive. Note that this will not fail if the 
  collection the set is supposed to live under doesn't exist.
  """
  @spec set_exists?(collection_name :: String.t, set_name :: String.t) :: boolean
  def set_exists?(collection_name, set_name), do: File.exists?(join([base_dir(), collection_name, set_name]))

  @doc """
  Creates a collection in the archive. Returns an error tuple if the collection
  already exists. If creating a nested collection, will only error if the final
  sub-collection already exists.
  """
  @spec create_collection(collection_name_or_names :: String.t | list(String.t)) :: :ok | {:error, :eexist}
  def create_collection(collection_name_or_names) do
    do_create_collection(List.flatten([collection_name_or_names]), base_dir())
  end
  defp do_create_collection([collection_name], cwd) when is_binary(collection_name) do
    path = join(cwd, collection_name)
    cond do
      File.exists?(path) -> {:error, :eexist}
      true -> File.mkdir!(path)
    end
  end
  defp do_create_collection([collection_name | rest], cwd) do
    path = join(cwd, collection_name)
    cond do
      File.exists?(path) -> do_create_collection(rest, path)
      true -> File.mkdir!(path); do_create_collection(rest, path)
    end
  end

  @doc """
  Deletes a collection in the archive. Will return an error if the collection
  doesn't exist. If success, returns a tuple with the names of the deleted files.
  """
  @spec delete_collection(collection_name_or_names :: String.t | list(String.t)) :: {:ok, [String.t]} | {:error, :no_collection}
  def delete_collection(collection_name_or_names) do
    cond do
      collection_exists?(collection_name_or_names) -> File.rm_rf collection_path(collection_name_or_names)
      true -> {:error, :no_collection}
    end
  end

  @doc """
  Creates a set within a collection. Will fail if the collection isn't present in the
  archive, or if the collection already exists.
  """
  @spec create_set(collection_name :: String.t, set_name :: String.t) :: :ok | {:error, :eexist} | {:error, :no_collection}
  def create_set(collection_name, set_name) do
    cond do
      not collection_exists?(collection_name) -> {:error, :no_collection}
      set_exists?(collection_name, set_name) -> {:error, :eexist}
      true -> File.mkdir set_path(collection_name, set_name)
    end
  end

  @doc """
  Deletes a set within a collection. Will fail if the collection doesn't exist, or if the 
  set doesn't exist.
  """
  @spec delete_set(collection_name :: String.t, set_name :: String.t) :: {:ok, [String.t]} | {:error, :no_collection} | {:error, :no_set}
  def delete_set(collection_name, set_name) do
    cond do
      not collection_exists?(collection_name) -> {:error, :no_collection}
      not set_exists?(collection_name, set_name) -> {:error, :no_set}
      set_exists?(collection_name, set_name) -> File.rm_rf set_path(collection_name, set_name)
    end
  end

end
