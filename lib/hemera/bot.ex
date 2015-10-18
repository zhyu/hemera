defmodule Hemera.Bot do
  alias Hemera.Anime
  alias Nadia.Model.Message
  alias Nadia.Model.Chat

  @doc """
  pull updates and send to dispatcher
  """
  def pull_updates(offset \\ -1) do
    case bot_api.get_updates(offset: offset) do
      {:ok, updates} when length(updates) > 0 ->
        offset = List.last(updates).update_id + 1
        Hemera.Dispatcher.dispatch_updates(updates)
        :timer.sleep(200)
      _ -> :timer.sleep(500)
    end
    pull_updates(offset)
  end

  @doc """
  handle incoming message
  """
  def handle_message(%Message{chat: %Chat{type: "private", id: chat_id}, text: text}) do
    handle_private_message(chat_id, text)
  end

  # fallback
  def handle_message(_), do: true

  defp handle_private_message(chat_id, "ping") do
    bot_api.send_message(chat_id, "pong")
  end

  defp handle_private_message(chat_id, "/set_anime_reminder") do
    Anime.add_user(chat_id)

    reply = """
    If you want to custom tv channels you'd like to watch, you can sign up at:
    http://cal.syoboi.jp/usr

    After finish setting up your account, let me know by "/set_anime_user $username".

    Otherwise, you will be notified of animes from all tv channels.
    """
    bot_api.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, "/set_anime_user") do
    bot_api.send_message(chat_id, "Please specify your username.")
  end

  defp handle_private_message(chat_id, "/set_anime_user " <> username) do
    Anime.add_user(chat_id)
    Anime.set_username(chat_id, username)

    reply = "GJ! You will be notified of animes from tv channels you selected."
    bot_api.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, _) do
    :random.seed(:os.timestamp)
    bot_api.send_sticker(chat_id, random_sticker)
  end

  defp bot_api, do: Application.get_env(:hemera, :bot_api)

  defp get_conf, do: Application.get_env(:hemera, Bot)

  defp stickers, do: get_conf[:stickers]

  defp random_sticker, do: Enum.random(stickers)
end
