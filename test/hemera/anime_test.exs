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

    assert Anime.get_users |> Enum.sort == ~w(666 777)
  end

  test "username" do
    assert Anime.set_username(666, "lol") == {:ok, 1}

    assert Anime.get_username(666) == "lol"
  end

  test "anime_rss" do
    assert Anime.add_rss(666, "rss1") == {:ok, 1}

    assert Anime.get_rss_list(666) == ~w(rss1)

    assert Anime.add_rss(666, "rss2") == {:ok, 1}

    assert 666 |> Anime.get_rss_list |> Enum.sort == ~w(rss1 rss2)
  end
end
