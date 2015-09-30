defmodule Hemera.Anime do
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
end
