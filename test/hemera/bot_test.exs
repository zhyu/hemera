defmodule Hemera.BotTest do
  use ExUnit.Case

  alias Nadia.Model.Message
  alias Nadia.Model.User

  setup_all do
    Application.put_env(:hemera, :bot_api, Telegram.TestClient)
    Application.put_env(:hemera, Bot, sticker_id: "test_sticker")
    :ok
  end

  test "ping" do
    {:ok, res} = Hemera.Bot.handle_message(%Message{chat: %User{id: 666}, text: "ping"})
    assert res == "Send message to 666: pong"
  end

  test "sticker" do
    {:ok, res} = Hemera.Bot.handle_message(%Message{chat: %User{id: 666}, text: "hi"})
    assert res == "Send sticker to 666: test_sticker"
  end
end

defmodule Telegram.Marco do
  defmacro gen_send_func(item) do
    quote do
      def unquote(:"send_#{item}")(chat_id, content) do
        {:ok, "Send #{unquote(item)} to #{chat_id}: #{content}"}
      end
    end
  end
end

defmodule Telegram.TestClient do
  import Telegram.Marco

  gen_send_func :message
  gen_send_func :sticker
end
