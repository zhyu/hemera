defmodule Hemera.Anime do
  alias Hemera.RedisPool, as: Redis
  alias Hemera.User
  alias Timex.Date
  alias Timex.DateFormat
  alias Timex.Time

  @base_url "http://cal.syoboi.jp/rss2.php"
  @title_format "$(StTime)$(OffsetB)%20$(Mark)$(MarkW)%20[$(ChName)]|crlf|$(Title)|crlf|$(SubTitleB)"

  def add_rss(user_id, rss) do
    Redis.command(~w(SADD anime_rss:#{user_id} #{rss}))
  end

  def remove_rss(user_id, rss) do
    Redis.command(~w(SREM anime_rss:#{user_id} #{rss}))
  end

  def get_rss_list(user_id) do
    {:ok, rss_list} = Redis.command(~w(SMEMBERS anime_rss:#{user_id}))
    unless is_list(rss_list), do: rss_list = [rss_list]
    rss_list
  end

  def get_daily_anime(user_id) do
    %HTTPoison.Response{body: body} = user_id |> build_url |> HTTPoison.get!
    body
    |> Floki.find("item title")
    |> Enum.map_join("\n------\n", &Floki.FlatText.get/1)
    |> String.replace("|crlf|", "\n")
  end

  defp build_url(user_id) do
    username = User.get_name(user_id)
    "#{@base_url}?titlefmt=#{@title_format}&end=#{end_of_today}&usr=#{username}"
  end

  # 0600 of tomorrow
  defp end_of_today do
    Date.local
    |> Date.add(Time.to_timestamp(1, :days))
    |> Date.set([hour: 6, minute: 0])
    |> DateFormat.format!("{YYYY}{0M}{0D}{h24}{m}")
  end
end
