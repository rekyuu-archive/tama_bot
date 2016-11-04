defmodule TelegramBot.Module do
  @bot Application.get_env(:telegram_bot, :username)

  defmacro __using__(_options) do
    quote do
      import TelegramBot.Module
    end
  end

  defp gen_command_matches(text, do: func) do
    quote do
      def match_msg(%{text: "/" <> unquote(text)} = var!(msg)) do
        Task.async(fn -> unquote(func) end)
      end

      def match_msg(%{text: "/" <> unquote(text) <> " " <> _} = var!(msg)) do
        Task.async(fn -> unquote(func) end)
      end

      def match_msg(%{text: "/" <> unquote(text) <> "@" <> unquote(@bot)} = var!(msg)) do
        Task.async(fn -> unquote(func) end)
      end

      def match_msg(%{text: "/" <> unquote(text) <> "@" <> unquote(@bot) <> " " <> _} = var!(msg)) do
        Task.async(fn -> unquote(func) end)
      end
    end
  end

  defp gen_text_matches(text, do: func) do
    quote do
      def match_msg(%{text: unquote(text)} = var!(msg)) do
        Task.async(fn -> unquote(func) end)
      end
    end
  end

  defmacro command(command_list, do: func) when is_list(command_list) do
    for text <- command_list, do: gen_command_matches(text, do: func)
  end

  defmacro command(text, do: func) do
    gen_command_matches(text, do: func)
  end

  defmacro match(match_list, do: func) when is_list(match_list) do
    for text <- match_list, do: gen_text_matches(text, do: func)
  end

  defmacro match(text, do: func) do
    gen_text_matches(text, do: func)
  end

  defmacro reply(text) do
    quote do
      Nadia.send_message(var!(msg).chat.id, unquote(text), [parse_mode: "Markdown"])
    end
  end

  defmacro reply_no_preview(text) do
    quote do
      Nadia.send_message(var!(msg).chat.id, unquote(text), [disable_web_page_preview: true, parse_mode: "Markdown"])
    end
  end

  defmacro reply_photo(photo) do
    quote do
      Nadia.send_photo(var!(msg).chat.id, unquote(photo))
    end
  end

  defmacro reply_photo_with_caption(photo, text) do
    quote do
      Nadia.send_photo(var!(msg).chat.id, unquote(photo), [caption: unquote(text)])
    end
  end
end
