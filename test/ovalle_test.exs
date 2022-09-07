defmodule OvalleTest do
  use ExUnit.Case
  doctest Ovalle

  describe "test environment" do
    test "reads config" do
      assert is_binary(Application.fetch_env!(:ovalle, :archive_dir))
      assert_raise ArgumentError, fn ->
        Application.fetch_env!(:ovalle, :non_existant_env)
      end
    end

    test "creates a test folder" do
      test_folder = Application.fetch_env!(:ovalle, :archive_dir)
      assert File.exists?(test_folder)
    end
  end

end
