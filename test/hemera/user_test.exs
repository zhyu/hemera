defmodule Hemera.UserTest do
  use ExUnit.Case

  alias Hemera.User

  setup_all do
    Hemera.RedisPool.command(["FLUSHDB"])
    :ok
  end

  test "add and get" do
    User.add(777)
    user_list = User.get_list

    assert is_list(user_list)
    assert "777" in user_list
  end

  test "username" do
    User.set_name(777, "lol")

    assert User.get_name(777) == "lol"
  end
end
