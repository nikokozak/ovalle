defmodule IngestTest do 
  use ExUnit.Case
  import Ovalle.FileUtils.Ingest
  alias Ovalle.FileUtils.Collection
  alias Ovalle.FileUtils.Document

  @ingest_dir "test_ingest"

  setup do
    archive_dir = Application.fetch_env!(:ovalle, :archive_dir)
    File.rm_rf!(archive_dir)
    File.mkdir(archive_dir)

    File.rm_rf!(@ingest_dir)
    File.mkdir(@ingest_dir)
    File.mkdir(Path.join(@ingest_dir, "one"))
    File.mkdir(Path.join(@ingest_dir, "two9012***"))
    File.mkdir(Path.join(@ingest_dir, "thr$$"))
    File.touch!(Path.join([@ingest_dir, "one", "a-file.pdf"]))
    File.touch!(Path.join([@ingest_dir, "one", ".a-hidden-file.pdf"]))
    File.touch!(Path.join([@ingest_dir, "two9012***", "another-file.pdf"]))
  end

  test "ingest/1" do
    :ok = ingest(@ingest_dir)
    assert Collection.exists?(@ingest_dir)
    assert Collection.exists?([@ingest_dir, "one"])
    assert Collection.exists?([@ingest_dir, "two9012"])
    refute Collection.exists?([@ingest_dir, "thr"])
    refute Collection.exists?([@ingest_dir, "thr$$"])

    assert Document.exists?([@ingest_dir, "one"], "a-file.pdf")
    refute Document.exists?([@ingest_dir, "one"], ".a-hidden-file.pdf")
    refute Document.exists?([@ingest_dir, "one"], "a-hidden-file.pdf")
    assert Document.exists?([@ingest_dir, "two9012"], "another-file.pdf")
  end

end
