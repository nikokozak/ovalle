
test_dir = Application.fetch_env!(:ovalle, :archive_dir)

# Make our test dir, after deleting a previous one
if File.exists?(test_dir), do: File.rm_rf!(test_dir)
File.mkdir!(test_dir)

ExUnit.start()

ExUnit.after_suite(fn _ -> 
 File.rm_rf!(test_dir)
end)

