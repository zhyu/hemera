defmodule Hemera.BotTest do
  use ExUnit.Case

  alias Hemera.User

  alias Nadia.Model.Message
  alias Nadia.Model.Chat

  import Hemera.Bot, only: [handle_message: 1]

  setup_all do
    Hemera.RedisPool.command(["FLUSHDB"])
    :ok
  end

  setup do
    context = %{message: %Message{chat: %Chat{id: 555, type: "private"}}}
    {:ok, context}
  end

  test "ping", context do
    handle_message(%{context.message | text: "ping"})
    assert_received {:message, 555, "pong"}
  end

  test "sticker", context do
    handle_message(%{context.message | text: "hi"})
    assert_received {:sticker, 555, "test_sticker"}
  end

  test "/add_user", context do
    handle_message(%{context.message | text: "/add_user"})
    assert_received {:message, 555, "You will be notified of animes from all tv channels." <> _}
    assert "555" in User.get_list
  end

  test "/set_username", context do
    handle_message(%{context.message | text: "/set_username"})
    assert_received {:message, 555, "Please specify your username."}

    handle_message(%{context.message | text: "/set_username lol"})
    assert_received {:message, 555, "You will be notified of animes from tv channels you selected."}
    assert User.get_name(555) == "lol"
  end

  test "anime rss", context do
    handle_message(%{context.message | text: "/show_rss_list"})
    assert_received {:message, 555, "Empty list! Use /add_rss $your_rss_link to add some."}

    handle_message(%{context.message | text: "/add_rss rss_link1"})
    assert_received {:message, 555, "GJ!"}

    handle_message(%{context.message | text: "/show_rss_list"})
    assert_received {:message, 555, "rss_link1"}

    handle_message(%{context.message | text: "/add_rss rss_link2"})
    assert_received {:message, 555, "GJ!"}

    handle_message(%{context.message | text: "/show_rss_list"})
    assert_received {:message, 555, "rss_link1\n------\nrss_link2"}

    handle_message(%{context.message | text: "/remove_rss rss_link1"})
    assert_received {:message, 555, "QAQ"}

    handle_message(%{context.message | text: "/show_rss_list"})
    assert_received {:message, 555, "rss_link2"}
  end
end
