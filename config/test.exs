use Mix.Config

config :hemera, Bot,
  stickers: ["test_sticker"]

config :hemera,
  bot_api: Hemera.Telegram.TestClient

config :quantum,
  cron: []
