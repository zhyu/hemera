defmodule Hemera.Telegram.Macro do
  defmacro gen_send_func(item) do
    quote do
      def unquote(:"send_#{item}")(chat_id, content) do
        send self, {unquote(item), chat_id, content}
      end
    end
  end
end
