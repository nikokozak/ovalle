defmodule CollectionTest do
  use ExUnit.Case
  import Ovalle.FileUtils.Collection

  @collection "ARMY"
  @nested_collection ["ARMY", "Argentina", "Kozak"]

  setup do
    archive_dir = Application.fetch_env!(:ovalle, :archive_dir)
    File.rm_rf!(archive_dir)
    File.mkdir(archive_dir)
  end

  describe "collection utils" do

    test "create_collection/1 creates single collection" do
      refute exists?(@collection)
      :ok = create(@collection)
      assert exists?(@collection)
      {:error, :eexist} = create(@collection)
    end

    test "create_collection/1 creates nested collections" do
      refute exists?(@nested_collection)
      :ok = create(@nested_collection)
      assert exists?(@nested_collection)
      {:error, :eexist} = create(@collection)
    end

    test "delete_collection/1 deletes a single collection" do
      :ok = create(@collection)
      assert exists?(@collection)

      {:ok, _} = delete(@collection)
      refute exists?(@collection)

      {:error, :no_collection} = delete(@collection)
    end

    test "delete_collection/1 deletes all connections nested beneath it" do
      :ok = create(@nested_collection)
      assert exists?(@nested_collection)

      {:ok, _} = delete(@collection)
      refute exists?(@collection)

      {:error, :no_collection} = delete(@collection)
    end

  end

end
