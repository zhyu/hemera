defmodule Hemera.Bot do
  alias Nadia.Model.Message
  alias Nadia.Model.User

  @doc """
  pull updates and send to dispatcher
  """
  def pull_updates(offset \\ -1) do
    {:ok, updates} = Nadia.get_updates(offset: offset)
    if length(updates) > 0 do
      offset = List.last(updates).update_id + 1
      Hemera.Dispatch.dispatch_updates(updates)
    end
    :timer.sleep(200)
    pull_updates(offset)
  end

  @doc """
  handle incoming message
  """
  def handle_message(%Message{chat: %User{id: user_id}, text: "ping"}) do
    Nadia.send_message(user_id, "pong")
  end

  # fallback
  def handle_message(_), do: true
end
