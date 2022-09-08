defmodule Ovalle.FileUtils.Collection do
  import Ovalle.FileUtils, only: [base_dir: 0]
  import Path, only: [join: 1, join: 2]

  @spec path(collection_names :: list(String.t)) :: String.t
  def path(collection_names) when is_list(collection_names), do: join([ base_dir() | collection_names ])
  @spec path(collection_name :: String.t) :: String.t
  def path(collection_name), do: path([collection_name])

  @doc """
  Checks whether a collection exists in the archive.
  """
  @spec exists?(collection_name_or_names :: String.t | list(String.t)) :: boolean
  def exists?(collection_name_or_names), do: File.exists?(path(collection_name_or_names))

  @doc """
  Creates a collection in the archive. Returns an error tuple if the collection
  already exists. If creating a nested collection, will only error if the final
  sub-collection already exists.
  """
  @spec create(collection_name_or_names :: String.t | list(String.t)) :: :ok | {:error, :eexist}
  def create(collection_name_or_names) do
    do_create(List.flatten([collection_name_or_names]), base_dir())
  end
  defp do_create([collection_name], cwd) when is_binary(collection_name) do
    path = join(cwd, collection_name)
    cond do
      File.exists?(path) -> {:error, :eexist}
      true -> File.mkdir!(path)
    end
  end
  defp do_create([collection_name | rest], cwd) do
    path = join(cwd, collection_name)
    cond do
      File.exists?(path) -> do_create(rest, path)
      true -> File.mkdir!(path); do_create(rest, path)
    end
  end

  @doc """
  Deletes a collection in the archive. Will return an error if the collection
  doesn't exist. If success, returns a tuple with the names of the deleted files.
  """
  @spec delete(collection_name_or_names :: String.t | list(String.t)) :: {:ok, [String.t]} | {:error, :no_collection}
  def delete(collection_name_or_names) do
    cond do
      exists?(collection_name_or_names) -> File.rm_rf path(collection_name_or_names)
      true -> {:error, :no_collection}
    end
  end

end
