defmodule SetTest do
  use ExUnit.Case
  import Ovalle.FileUtils.Set
  alias Ovalle.FileUtils.Collection

  @nested_collection ["ARMY", "Argentina", "Kozak"]
  @set_file "a-new-set.pdf"

  setup do
    archive_dir = Application.fetch_env!(:ovalle, :archive_dir)
    File.rm_rf!(archive_dir)
    File.mkdir(archive_dir)
  end

  describe "set utils" do

    test "create_set_for/2" do
      {:error, :no_collection} = create_for(@nested_collection, @set_file)

      :ok = Collection.create(@nested_collection)
      refute exists?(@nested_collection, @set_file)

      :ok = create_for(@nested_collection, @set_file)
      assert exists?(@nested_collection, @set_file)

      {:error, :eexist} = create_for(@nested_collection, @set_file)
    end

    test "delete_set_for/2" do
      :ok = Collection.create(@nested_collection)
      :ok = create_for(@nested_collection, @set_file)

      {:error, :no_collection} = delete_for("a-non-existant-collection", @set_file)
      assert exists?(@nested_collection, @set_file)
      {:ok, [_]} = delete_for(@nested_collection, @set_file)
      refute exists?(@nested_collection, @set_file)
      {:error, :no_set} = delete_for(@nested_collection, @set_file)
    end

  end

end
