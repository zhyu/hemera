defmodule Hemera.Anime do
  defp get_conf, do: Application.get_env(:hemera, Anime)

  defp source_url, do: get_conf[:source_url]

  defp append_id(anime = %{"ChID" => chid, "TID" => tid, "PID" => pid}) do
    Dict.put(anime, "id", Enum.join([chid, tid, pid], "-"))
  end

  def fetch do
    %HTTPoison.Response{body: body}= source_url |> HTTPoison.get!
    body
    |> Poison.decode!
    |> Dict.get("items")
    |> Enum.map(&append_id/1)
  end
end
