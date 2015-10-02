defmodule Hemera.Bot do
  alias Nadia.Model.Message
  alias Nadia.Model.User

  @doc """
  pull updates and send to dispatcher
  """
  def pull_updates(offset \\ -1) do
    {:ok, updates} = bot_api.get_updates(offset: offset)
    if length(updates) > 0 do
      offset = List.last(updates).update_id + 1
      Hemera.Dispatch.dispatch_updates(updates)
    end
    :timer.sleep(200)
    pull_updates(offset)
  end

  @doc """
  handle incoming message
  """
  def handle_message(%Message{chat: %User{id: user_id}, text: "ping"}) do
    bot_api.send_message(user_id, "pong")
  end

  def handle_message(%Message{chat: %User{id: user_id}}) do
    bot_api.send_sticker(user_id, sticker)
  end

  # fallback
  def handle_message(_), do: true

  defp bot_api, do: Application.get_env(:hemera, :bot_api)

  defp get_conf, do: Application.get_env(:hemera, Bot)

  defp sticker, do: get_conf[:sticker_id]
end