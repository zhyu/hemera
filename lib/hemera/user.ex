defmodule Hemera.User do
  alias Hemera.RedisPool, as: Redis

  def add(user_id) do
    Redis.command(~w(SADD users #{user_id}))
  end

  def get_list do
    {:ok, users} = Redis.command(~w(SMEMBERS users))
    unless is_list(users), do: users = [users]
    users
  end

  def set_name(user_id, name) do
    Redis.command(~w(HSET user:#{user_id} name #{name}))
  end

  def get_name(user_id) do
    {:ok, name} = Redis.command(~w(HGET user:#{user_id} name))
    name
  end
end
