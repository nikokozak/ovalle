defmodule OvalleTest do
  use ExUnit.Case
  doctest Ovalle

  test "reads config" do
    assert is_binary(Application.fetch_env!(:ovalle, :archive_dir))
    assert_raise ArgumentError, fn ->
      Application.fetch_env!(:ovalle, :non_existant_env)
    end
  end

end
