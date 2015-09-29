defmodule Hemera.Dispatch do
  def dispatch_updates(updates) do
    updates
    |> Enum.each(&Task.Supervisor.start_child(Hemera.TaskSupervisor, Hemera.Bot, :handle_message, [&1.message]))
  end
end
