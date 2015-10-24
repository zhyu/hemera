defmodule Hemera.Bot do
  alias Hemera.Anime
  alias Hemera.User
  alias Nadia.Model.Message
  alias Nadia.Model.Chat

  @doc """
  Telegram Bot API. read config from environment.
  """
  def api, do: Application.get_env(:hemera, :bot_api)

  @doc """
  handle incoming message
  """
  def handle_message(%Message{chat: %Chat{type: "private", id: chat_id}, text: text}) do
    handle_private_message(chat_id, text)
  end

  # fallback
  def handle_message(_), do: true

  defp handle_private_message(chat_id, "ping") do
    api.send_message(chat_id, "pong")
  end

  defp handle_private_message(chat_id, "/add_user") do
    User.add(chat_id)

    reply = """
    You will be notified of animes from all tv channels.

    If you want to custom tv channels you'd like to watch, you can sign up at:
    http://cal.syoboi.jp/usr

    After finish setting up your account, let me know by "/set_username $username".
    """
    api.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, "/set_username") do
    api.send_message(chat_id, "Please specify your username.")
  end

  defp handle_private_message(chat_id, "/set_username " <> username) do
    User.set_name(chat_id, username)

    reply = "You will be notified of animes from tv channels you selected."
    api.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, "/show_daily_anime") do
    reply = Anime.get_daily_anime(chat_id)
    api.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, "/add_rss " <> rss) do
    Anime.add_rss(chat_id, rss)

    api.send_message(chat_id, "GJ!")
  end

  defp handle_private_message(chat_id, "/remove_rss " <> rss) do
    Anime.remove_rss(chat_id, rss)

    api.send_message(chat_id, "QAQ")
  end

  defp handle_private_message(chat_id, "/show_rss_list") do
    reply = chat_id
    |> Anime.get_rss_list
    |> Enum.sort
    |> Enum.join("\n------\n")

    if reply == "", do: reply = "Empty list! Use /add_rss $your_rss_link to add some."
    api.send_message(chat_id, reply)
  end

  defp handle_private_message(chat_id, _) do
    :random.seed(:os.timestamp)
    api.send_sticker(chat_id, random_sticker)
  end

  defp get_conf, do: Application.get_env(:hemera, Bot)

  defp stickers, do: get_conf[:stickers]

  defp random_sticker, do: Enum.random(stickers)
end
