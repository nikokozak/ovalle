defmodule FileUtilTest do
  use ExUnit.Case
  import Ovalle.FileUtils

  setup do
    archive_dir = Application.fetch_env!(:ovalle, :archive_dir)
    File.rm_rf!(archive_dir)
    File.mkdir(archive_dir)
  end

  test "clean_name/1" do
    file = "/once/again/1 .after. all this ${%}@time.ex"
    assert {"/once/again/1_after_all_this_time.ex", file} == clean_name(file)
  end

  test "hash!/1" do
    file = "test_file"
    File.write!(file, "some content")

    hash = hash!(file)
    
    File.write!(file, "some other content")

    hash_2 = hash!(file)

    refute hash == hash_2
    assert is_binary(hash) and is_binary(hash_2)
  end
  
end
