defmodule DocumentTest do 
  use ExUnit.Case
  alias Ovalle.FileUtils.Collection
  import Ovalle.FileUtils.Document

  @nested_collection ["ARMY", "Argentina", "Kozak"]

  setup do
    archive_dir = Application.fetch_env!(:ovalle, :archive_dir)
    File.rm_rf!(archive_dir)
    File.mkdir(archive_dir)
  end

  describe "document utils" do

    test "copy_document_into_collection/2" do
      file = "test_file.pdf"
      File.touch!(file)
      {:error, :no_collection} = copy_into_collection(@nested_collection, file)
      :ok = Collection.create(@nested_collection)
      :ok = copy_into_collection(@nested_collection, file)
      
      assert exists?(@nested_collection, file)

      File.rm!(file)
    end

  end

end
