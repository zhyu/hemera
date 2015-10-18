defmodule Hemera.Task do
  alias Hemera.Anime

  def send_daily_anime_to_users do
    Anime.get_users
    |> Enum.each(&Task.Supervisor.start_child(Hemera.TaskSupervisor, __MODULE__, :send_daily_anime_to_user, [&1]))
  end

  def send_daily_anime_to_user(user_id) do
    msg = Anime.get_daily_anime_for_user(user_id)
    Nadia.send_message(user_id, msg)
  end
end
