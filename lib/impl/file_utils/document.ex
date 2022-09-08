defmodule Ovalle.FileUtils.Document do
  import Path, only: [join: 2]
  alias Ovalle.FileUtils.Collection

  @spec path(collection_name_or_names :: String.t | list(String.t), filename :: String.t) :: String.t
  def path(collection_name_or_names, filename), do: join(Collection.path(collection_name_or_names), filename)

  @doc """
  Checks whether a document exists inside a given collection.
  """
  @spec exists?(collection_name_or_names :: String.t | list(String.t), filename :: String.t) :: boolean
  def exists?(collection_name_or_names, filename), do: File.exists?(path(collection_name_or_names, filename))

  @doc """
  Copies a document into a collection.
  """
  @spec copy_into_collection(collection_name_or_names :: String.t | list(String.t), path_to_file :: String.t) :: :ok | {:error, :no_collection}
  def copy_into_collection(collection_name_or_names, path_to_file) do
    cond do
      not Collection.exists?(collection_name_or_names) -> {:error, :no_collection}
      true -> File.cp!(path_to_file, path(collection_name_or_names, path_to_file))
    end
  end

end
