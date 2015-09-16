defmodule Hemera do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Hemera.RedisPool, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Hemera.Supervisor)
  end
end
