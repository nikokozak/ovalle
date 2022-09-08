defmodule Ovalle.FileUtils.Set do
  alias Ovalle.FileUtils.Collection
  import Path, only: [join: 2]

  @spec path(collection_name_or_names :: String.t | list(String.t), set_name :: String.t) :: String.t
  defp path(collection_name_or_names, filename) do
    set_name = name_from_filename(filename)
    join(Collection.path(collection_name_or_names), set_name)
  end

  @doc """
  Checks whether a set exists for a given file in the archive. Note that this will not fail if the collection the set is supposed to live under doesn't exist (it will simply return false).
  """
  @spec exists?(collection_name_or_names :: String.t | list(String.t), filename :: String.t) :: boolean
  def exists?(collection_name_or_names, filename), do: File.exists?(path(collection_name_or_names, filename))

  @doc """
  Returns the name of the hidden set folder for a given filename.

  ## Examples
  
    iex> Ovalle.FileUtils.name_from_filename("a-file.pdf")
    ".a-file-set"
  """
  @spec name_from_filename(filename :: String.t) :: String.t
  def name_from_filename(filename), do: ".#{Path.basename(filename) |> Path.rootname}-set"

  @doc """
  Creates a set within a collection. Will fail if the collection isn't present in the
  archive, or if the collection already exists.
  """
  @spec create_for(collection_name_or_names :: String.t | list(String.t), filename :: String.t) :: :ok | {:error, :eexist} | {:error, :no_collection}
  def create_for(collection_name_or_names, filename) do
    cond do
      not Collection.exists?(collection_name_or_names) -> {:error, :no_collection}
      exists?(collection_name_or_names, filename) -> {:error, :eexist}
      true -> File.mkdir path(collection_name_or_names, filename)
    end
  end

  @doc """
  Deletes a set within a collection. Will fail if the collection doesn't exist, or if the 
  set doesn't exist.
  """
  @spec delete_for(collection_name_or_names :: String.t, filename :: String.t) :: {:ok, [String.t]} | {:error, :no_collection} | {:error, :no_set}
  def delete_for(collection_name, filename) do
    cond do
      not Collection.exists?(collection_name) -> {:error, :no_collection}
      not exists?(collection_name, filename) -> {:error, :no_set}
      exists?(collection_name, filename) -> File.rm_rf path(collection_name, filename)
    end
  end

end
