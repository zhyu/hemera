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
      Hemera.Dispatcher.dispatch_updates(updates)
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

  def handle_message(%Message{chat: %User{id: user_id}, text: "/set_anime_reminder"}) do
    Hemera.RedisPool.command(~w(SADD anime_users #{user_id}))

    reply = """
    If you want to custom tv channels you'd like to watch, you can sign up at:
    http://cal.syoboi.jp/usr

    After finish setting up your account, let me know by "/set_anime_user $username".

    Otherwise, you will be notified of animes from all tv channels.
    """
    bot_api.send_message(user_id, reply)
  end

  def handle_message(%Message{chat: %User{id: user_id}, text: "/set_anime_user"}) do
    bot_api.send_message(user_id, "Please specify your username.")
  end

  def handle_message(%Message{chat: %User{id: user_id}, text: "/set_anime_user " <> username}) do
    [~w(SADD anime_users #{user_id}), ~w(HSET anime_user:#{user_id} name #{username})]
    |> Hemera.RedisPool.pipeline

    reply = "GJ! You will be notified of animes from tv channels you selected."
    bot_api.send_message(user_id, reply)
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
