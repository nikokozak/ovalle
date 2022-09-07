import Config

config :ovalle,
  archive_dir: "archive"

import_config "#{config_env()}.exs"
