defmodule Ovalle.Document do

  @type t :: %{
    id: String.t,
    abs_path: String.t,
    rel_path: String.t,
    type: String.t,
    rootname: String.t,
    original_filename: String.t,
    hash: String.t,
    collection: String.t,
    added_at: DateTime.t(),
    size: integer(),
    searchable: boolean,
    meta: map()
  }

  defstruct [
    :id, 
    :abs_path, 
    :rel_path, 
    :type, 
    :rootname, 
    :original_filename,
    :hash, 
    :collection, 
    :added_at,
    :size, 
    :searchable,
    :meta, 
  ]

  @doc """
  `ingest/1` is a callback implemented by specific filetype modules,
  allowing for different pipelines for ingesting documents and performing
  actions on them.
  """
  @callback ingest(filepath :: String.t) :: t()

end
