defmodule Hemera.Anime do
  alias Hemera.RedisPool, as: Redis
  alias Timex.Date
  alias Timex.DateFormat
  alias Timex.Time

  import SweetXml

  @base_url "http://cal.syoboi.jp/rss2.php"
  @title_format "$(StTime)$(OffsetB)%20$(Mark)$(MarkW)%20[$(ChName)]|crlf|$(Title)|crlf|$(SubTitleB)"

  def add_user(user_id) do
    Redis.command(~w(SADD anime_users #{user_id}))
  end

  def get_users do
    {:ok, users} = Redis.command(~w(SMEMBERS anime_users))
    unless is_list(users), do: users = [users]
    users
  end

  def set_username(user_id, username) do
    Redis.command(~w(HSET anime_user:#{user_id} name #{username}))
  end

  def get_username(user_id) do
    {:ok, username} = Redis.command(~w(HGET anime_user:#{user_id} name))
    username
  end

  def add_rss(user_id, rss) do
    Redis.command(~w(SADD anime_rss:#{user_id} #{rss}))
  end

  def get_rss_list(user_id) do
    {:ok, rss_list} = Redis.command(~w(SMEMBERS anime_rss:#{user_id}))
    unless is_list(rss_list), do: rss_list = [rss_list]
    rss_list
  end

  def get_daily_anime(user_id) do
    %HTTPoison.Response{body: body} = user_id |> build_url |> HTTPoison.get!
    body
    |> xpath(~x"//item/title/text()"sl)
    |> Enum.map_join("\n------\n", &String.replace(&1, "|crlf|", "\n"))
  end

  defp build_url(user_id) do
    username = get_username(user_id)
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
