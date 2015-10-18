defmodule Hemera do
  use Application

  @task_name Hemera.Task
  @task_supervisor_name Hemera.TaskSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Hemera.RedisPool, []),
      supervisor(Task.Supervisor, [[name: @task_supervisor_name]]),
      worker(Task, [@task_name, :pull_updates, []])
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Hemera.Supervisor)
  end
end
