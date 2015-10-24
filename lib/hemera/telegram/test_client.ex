defmodule Hemera.Telegram.TestClient do
  import Hemera.Telegram.Macro

  gen_send_func :message
  gen_send_func :sticker

  def get_updates(options \\ []), do: {:ok, []}
end
