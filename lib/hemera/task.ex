defmodule Hemera.Task do
  alias Hemera.Anime

  @doc """
  pull updates and send to dispatcher
  """
  def pull_updates(offset \\ -1) do
    case Hemera.Bot.api.get_updates(offset: offset) do
      {:ok, updates} when length(updates) > 0 ->
        offset = List.last(updates).update_id + 1
        Hemera.Dispatcher.dispatch_updates(updates)
        :timer.sleep(200)
      _ -> :timer.sleep(500)
    end
    pull_updates(offset)
  end

  def send_daily_anime do
    Anime.get_users
    |> Enum.each(&Task.Supervisor.start_child(Hemera.TaskSupervisor, __MODULE__, :send_daily_anime, [&1]))
  end

  def send_daily_anime(user_id) do
    msg = Anime.get_daily_anime(user_id)
    Hemera.Bot.api.send_message(user_id, msg)
  end
end
