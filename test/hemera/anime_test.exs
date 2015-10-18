defmodule Hemera.AnimeTest do
  use ExUnit.Case

  alias Hemera.Anime
  alias Hemera.RedisPool, as: Redis

  setup_all do
    Redis.start_link
    Redis.command(["FLUSHDB"])
    :ok
  end

  test "anime users" do
    assert Anime.add_user(666) == {:ok, 1}

    assert Anime.get_users == ~w(666)

    assert Anime.add_user(777) == {:ok, 1}

    assert Anime.get_users == ~w(666 777)
  end

  test "username" do
    assert Anime.set_username(666, "lol") == {:ok, 1}

    assert Anime.get_username(666) == "lol"
  end
end
