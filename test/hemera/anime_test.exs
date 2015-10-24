defmodule Hemera.AnimeTest do
  use ExUnit.Case

  alias Hemera.Anime

  setup_all do
    Hemera.RedisPool.command(["FLUSHDB"])
    :ok
  end

  test "anime_rss" do
    Anime.add_rss(666, "rss1")
    rss_list = Anime.get_rss_list(666)

    assert is_list(rss_list)
    assert "rss1" in rss_list

    Anime.remove_rss(666, "rss1")
    rss_list = Anime.get_rss_list(666)

    assert is_list(rss_list)
    refute "rss1" in rss_list
  end
end
