use Mix.Config

config :hemera, Bot,
  stickers: ["sticker1", "sticker2"]

config :hemera,
  bot_api: Nadia

config :quantum,
  cron: [
  #"0 8,18 * * *": {Hemera.Task, :send_daily_anime}
  ],
  timezone: :local

config :nadia,
  token: "bot_token"

config :logger, :console,
  level: :info,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:user_id]

import_config "#{Mix.env}.exs"
