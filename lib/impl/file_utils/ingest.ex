defmodule Ovalle.FileUtils.Ingest do
  alias Ovalle.FileUtils.{Collection, Document}

  def ingest(path_to_folder) do
    path_to_folder
    |> folder_structure
    |> sanitize_folder_structure
    |> copy_sanitized
  end

  @doc """
  Copies a folder from outside the archive into the archive, ensuring that collections
  are created and all names are sanitized. Will not copy in empty collections.
  """
  @spec copy_sanitized(sanitized_struct :: list(String.t)) :: :ok
  def copy_sanitized([{_clean, _original} = _empty_folder, []]), do: :ok
  def copy_sanitized([folder | rest]) when is_list(folder) do
    copy_sanitized(folder)
    copy_sanitized(rest)
  end
  def copy_sanitized([{clean, original} | rest]) do
    cond do
      File.dir?(original) -> 
        Collection.create(Path.split(clean))
        copy_sanitized(rest)
      true -> 
        Document.copy_into_collection(Path.dirname(clean) |> Path.split, original, new_filename: Path.basename(clean))
        copy_sanitized(rest)
    end
  end
  def copy_sanitized([]), do: :ok

  @doc """
  Accepts a folder structure and returns a folder structure where every element is a tuple,
  the first element of the tuple being the new, sanitized path, and the old element being the
  second element of the tuple.
  """
  @spec sanitize_folder_structure(folder_structure :: String.t | list(String.t)) :: String.t | list(String.t)
  def sanitize_folder_structure([element | rest]) when is_binary(element) do
    [ Ovalle.FileUtils.clean_path_and_name(element) | sanitize_folder_structure(rest) ]
  end
  def sanitize_folder_structure([element | rest]) when is_list(element) do
    [ sanitize_folder_structure(element) | sanitize_folder_structure(rest) ]
  end
  def sanitize_folder_structure([]), do: []
  def sanitize_folder_structure(file_name) when is_binary(file_name) do
    Ovalle.FileUtils.clean_path_and_name(file_name)
  end

  @doc """
  Traverses a folder and returns its structure as a series of nested lists, or a
  single filename if no folder was found at the path.
  """
  @spec folder_structure(file_or_folder :: String.t) :: list(String.t) | String.t
  def folder_structure(file_or_folder) do
    if File.dir?(file_or_folder) do
      [ file_or_folder, do_folder_structure(Path.wildcard(Path.join(file_or_folder, "*"))) ]
    else
      file_or_folder
    end
  end

  defp do_folder_structure([]), do: []
  defp do_folder_structure([ first | rest ]) do
    cond do 
      File.dir?(first) -> [[ first, do_folder_structure(Path.wildcard(Path.join(first, "*"))) ]] ++ do_folder_structure(rest)
      true -> [ first ] ++ do_folder_structure(rest) 
    end
  end

end
