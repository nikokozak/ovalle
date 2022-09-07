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
    :size, 
    :meta, 
    :added_at
  ]
  
  @callback new(filepath :: String.t) :: t()
  @callback different?(old :: t, new :: t) :: t()

end
