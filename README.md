# Ovalle

# TODO

- Dockerize for dev
- Add utilities for crawling, flattening archives
- Add hashing of files for version checking
- Add utility for identifying already-imported collection (plant a file)
- Add utilities to diff import folders
- Add state tracker to store all transformations of file as it goes through the process
- Add utils for monitoring intermediate process in file transforms
- Add sqlite database (or light elixir alternative w/adapter)
- Add interface for ocr_my_pdf and imagemagik

# DESIGN

## Purpose

Ovalle is a niche system that allows files to be organized hierarchically in a standard way.

Ovalle allows us to import, transform, and process archival files, while keeping track of pre-existing collections
and files in the system.

Ovalle is extensible, meaning new pipelines can be created for new filetypes, and external functions can be injected
into the pipeline as well.

Ovalle is, ultimately, a tool to standardize ingest processes for archival files - a naive document management system.

## System

Files are part of Collections. 

An Original file has an associated Set (found at `.set/`, which is a series of files derived
from the Original (like extracted text, thumbnails, and metadata).

Whenever a file is imported, Ovalle checks for files with the same name, and compares hash
values to determine whether the new file is different. If so, it will re-process the file.

Processing of files is handled by agents, which can be queried to determine the status of processing.

Ovalle keeps track of existing collections, files, and set files with an SQLite database, handled by the `Repo` module.
