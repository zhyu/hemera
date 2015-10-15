defmodule Hemera.Anime do
  alias Hemera.RedisPool, as: Redis
  alias Timex.Date
  alias Timex.DateFormat
  alias Timex.Time

  import SweetXml

  @base_url "http://cal.syoboi.jp/rss2.php"
  @title_format "$(StTime)$(OffsetB)%20$(Mark)$(MarkW)%20[$(ChName)]|crlf|$(Title)|crlf|$(SubTitleB)"

  defp get_conf, do: Application.get_env(:hemera, Anime)

  defp source_url, do: get_conf[:source_url]

  defp save_to_redis(item = %{"PID" => pid, "StTime" => start_time}) do
    [["SET", pid, Poison.encode!(item), "EX", "86400"],
    ["ZADD", "anime", start_time, pid]]
  end

  def collect do
    %HTTPoison.Response{body: body}= source_url |> HTTPoison.get!
    body
    |> Poison.decode!
    |> Dict.get("items")
    |> Enum.flat_map(&save_to_redis/1)
    |> List.insert_at(0, ["DEL", "anime"])
    |> Hemera.RedisPool.pipeline
  end

  def add_user(user_id) do
    Redis.command(~w(SADD anime_users #{user_id}))
  end

  def get_users do
    {:ok, users} = Redis.command(~w(SMEMBERS anime_users))
    users
  end

  def set_username(user_id, username) do
    Redis.command(~w(HSET anime_user:#{user_id} name #{username}))
  end

  def get_username(user_id) do
    {:ok, username} = Redis.command(~w(HGET anime_user:#{user_id} name))
    username
  end

  def get_for_user(user_id) do
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
    Date.now
    |> Date.add(Time.to_timestamp(1, :days))
    |> Date.set([hour: 6, minute: 0])
    |> DateFormat.format!("{YYYY}{0M}{0D}{h24}{m}")
  end
end
