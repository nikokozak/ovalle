defmodule Ovalle.FileUtils do
  import Path, only: [join: 2, join: 1]

  @moduledoc """
  Provides utilities for working with files. 

  `collection`s can be nested.
  `set`s are hidden folders named based on a given document, containing other documents derived
  from the original.
  `document`s are the base files that are stored in the system.
  """

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
  defp set_path(collection_name_or_names, filename) do
    set_name = set_name_from_filename(filename)
    join(collection_path(collection_name_or_names), set_name)
  end

  @spec document_path(collection_name_or_names :: String.t | list(String.t), filename :: String.t) :: String.t
  defp document_path(collection_name_or_names, filename), do: join(collection_path(collection_name_or_names), filename)

  ######################################## 

  @doc """
  Checks whether a collection exists in the archive.
  """
  @spec collection_exists?(collection_name_or_names :: String.t | list(String.t)) :: boolean
  def collection_exists?(collection_name_or_names), do: File.exists?(collection_path(collection_name_or_names))

  @doc """
  Checks whether a document exists inside a given collection.
  """
  @spec document_exists?(collection_name_or_names :: String.t | list(String.t), filename :: String.t) :: boolean
  def document_exists?(collection_name_or_names, filename), do: File.exists?(document_path(collection_name_or_names, filename))

  @doc """
  Copies a document into a collection.
  """
  @spec copy_document_into_collection(collection_name_or_names :: String.t | list(String.t), path_to_file :: String.t) :: :ok | {:error, :no_collection}
  def copy_document_into_collection(collection_name_or_names, path_to_file) do
    cond do
      not collection_exists?(collection_name_or_names) -> {:error, :no_collection}
      true -> File.cp!(path_to_file, document_path(collection_name_or_names, path_to_file))
    end
  end

  @doc """
  Checks whether a set exists for a given file in the archive. Note that this will not fail if the collection the set is supposed to live under doesn't exist (it will simply return false).
  """
  @spec set_exists?(collection_name_or_names :: String.t | list(String.t), set_name :: String.t) :: boolean
  def set_exists?(collection_name_or_names, filename), do: File.exists?(set_path(collection_name_or_names, filename))

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
  Returns the name of the hidden set folder for a given filename.

  ## Examples
  
    iex> Ovalle.FileUtils.set_name_from_filename("a-file.pdf")
    ".a-file-set"
  """
  @spec set_name_from_filename(filename :: String.t) :: String.t
  def set_name_from_filename(filename), do: ".#{Path.basename(filename) |> Path.rootname}-set"

  @doc """
  Creates a set within a collection. Will fail if the collection isn't present in the
  archive, or if the collection already exists.
  """
  @spec create_set_for(collection_name_or_names :: String.t | list(String.t), filename :: String.t) :: :ok | {:error, :eexist} | {:error, :no_collection}
  def create_set_for(collection_name_or_names, filename) do
    cond do
      not collection_exists?(collection_name_or_names) -> {:error, :no_collection}
      set_exists?(collection_name_or_names, filename) -> {:error, :eexist}
      true -> File.mkdir set_path(collection_name_or_names, filename)
    end
  end

  @doc """
  Deletes a set within a collection. Will fail if the collection doesn't exist, or if the 
  set doesn't exist.
  """
  @spec delete_set_for(collection_name_or_names :: String.t, filename :: String.t) :: {:ok, [String.t]} | {:error, :no_collection} | {:error, :no_set}
  def delete_set_for(collection_name, filename) do
    cond do
      not collection_exists?(collection_name) -> {:error, :no_collection}
      not set_exists?(collection_name, filename) -> {:error, :no_set}
      set_exists?(collection_name, filename) -> File.rm_rf set_path(collection_name, filename)
    end
  end

  @doc """
  Cleans a filename.

  ## Examples
  
    iex> Ovalle.FileUtils.clean_name("/once/again/1 .after. all this ${%}@time.ex")
    { "/once/again/1_after_all_this_time.ex", "/once/again/1 .after. all this ${%}@time.ex" }
  """
  @spec clean_name(filename :: String.t) :: {cleaned :: String.t, original :: String.t}
  def clean_name(filename) do
    dirs = dirpath(filename)
    extension = Path.extname(filename)
    root = Path.basename(filename) |> Path.rootname()

    filter = ["~", "`", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "=", "+", "[", "{", "]", "}", "\\", "|", ";", ":", "\"", "'", "&#8216;", "&#8217;", "&#8220;", "&#8221;", "&#8211;", "&#8212;", "â€”", "â€“", ",", "<", ".", ">", "/", "?"]

    cleaned = String.replace(root, filter, "")
              |> String.replace(~r/\s+/, "_")
              |> String.replace(~r/[^0-9a-zA-Z_-]/, "")

    { join(dirs, cleaned <> extension), filename }
  end

  defp dirpath(filename) do
    case Path.dirname(filename) do
      "." -> ""
      path -> path
    end
  end

end
