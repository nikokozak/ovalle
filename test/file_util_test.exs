defmodule FileUtilTest do
  use ExUnit.Case
  import Ovalle.FileUtils

  @collection "ARMY"
  @nested_collection ["ARMY", "Argentina", "Kozak"]
  @set_file "a-new-set.pdf"

  setup do
    archive_dir = Application.fetch_env!(:ovalle, :archive_dir)
    File.rm_rf!(archive_dir)
    File.mkdir(archive_dir)
  end

  describe "collection utils" do

    test "create_collection/1 creates single collection" do
      collection_path = Path.join(base_dir(), @collection)
      refute File.exists?(collection_path)
      :ok = create_collection(@collection)
      assert File.exists?(collection_path)
      {:error, :eexist} = create_collection(@collection)
    end

    test "create_collection/1 creates nested collections" do
      refute collection_exists?(@nested_collection)
      :ok = create_collection(@nested_collection)
      assert collection_exists?(@nested_collection)
      {:error, :eexist} = create_collection(@collection)
    end

    test "delete_collection/1 deletes a single collection" do
      :ok = create_collection(@collection)
      assert collection_exists?(@collection)

      {:ok, _} = delete_collection(@collection)
      refute collection_exists?(@collection)

      {:error, :no_collection} = delete_collection(@collection)
    end

    test "delete_collection/1 deletes all connections nested beneath it" do
      :ok = create_collection(@nested_collection)
      assert collection_exists?(@nested_collection)

      {:ok, _} = delete_collection(@collection)
      refute collection_exists?(@collection)

      {:error, :no_collection} = delete_collection(@collection)
    end

  end

  describe "set utils" do

    test "create_set_for/2" do
      {:error, :no_collection} = create_set_for(@nested_collection, @set_file)

      :ok = create_collection(@nested_collection)
      refute set_exists?(@nested_collection, @set_file)

      :ok = create_set_for(@nested_collection, @set_file)
      assert set_exists?(@nested_collection, @set_file)

      {:error, :eexist} = create_set_for(@nested_collection, @set_file)
    end

    test "delete_set_for/2" do
      :ok = create_collection(@nested_collection)
      :ok = create_set_for(@nested_collection, @set_file)

      {:error, :no_collection} = delete_set_for("a-non-existant-collection", @set_file)
      assert set_exists?(@nested_collection, @set_file)
      {:ok, [_]} = delete_set_for(@nested_collection, @set_file)
      refute set_exists?(@nested_collection, @set_file)
      {:error, :no_set} = delete_set_for(@nested_collection, @set_file)
    end

  end
  
end
