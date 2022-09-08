defmodule Ovalle.FileUtils do
  import Path, only: [join: 2]

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

  @doc """
  Creates a hash binary from a file.
  """
  @spec hash!(path_to_file :: String.t) :: String.t
  def hash!(path_to_file) do
    File.read!(path_to_file)
    |> (&(:crypto.hash(:md5, &1))).()
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

    cleaned = clean(root)

    { join(dirs, cleaned <> extension), filename }
  end

  defp clean("/"), do: "/"
  defp clean(string) do
    filter = ["~", "`", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "=", "+", "[", "{", "]", "}", "\\", "|", ";", ":", "\"", "'", "&#8216;", "&#8217;", "&#8220;", "&#8221;", "&#8211;", "&#8212;", "â€”", "â€“", ",", "<", ".", ">", "/", "?"]

    String.replace(string, filter, "")
    |> String.replace(~r/\s+/, "_")
    |> String.replace(~r/[^0-9a-zA-Z_-]/, "")
  end

  @doc """
  Cleans all portions of a path, returning the cleaned version and the original in a tuple.
  """
  @spec clean_path_and_name(filename :: String.t) :: {cleaned :: String.t, original :: String.t}
  def clean_path_and_name(filename) do
    dirs = dirpath(filename)
    file = Path.basename(filename)

    clean_dirs = Path.split(dirs) 
                 |> Enum.map(&clean/1)
                 |> joinpath

    {clean_file, _} = clean_name(file)

    {Path.join(clean_dirs, clean_file), filename}
  end

  defp joinpath([]), do: ""
  defp joinpath(path), do: Path.join(path)

  defp dirpath(filename) do
    case Path.dirname(filename) do
      "." -> ""
      path -> path
    end
  end

end
