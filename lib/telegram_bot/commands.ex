defmodule TelegramBot.Commands do
  use TelegramBot.Module
  import TelegramBot.Util
  require Logger

  command "tama" do
    id = rekyuu_id
    case msg.from.id do
      ^id ->
        Logger.log :warn, "== DEBUG =="
        Logger.log :debug, "msg.chat.id: #{msg.chat.id}"
        Logger.log :debug, "msg.chat.type: #{msg.chat.type}"
        Logger.log :debug, "msg.from.id: #{msg.from.id}"
        Logger.log :debug, "msg.from.username: @#{msg.from.username}"
        Logger.log :debug, "msg.text: #{msg.text}"

        reply "Nya ~"
      _ ->
        reply "I'm not allowed to talk to strangers, nya."
        rekyuu "Someone strange tried talking to me just nyow."
    end
  end

  command "draw" do
    id = rekyuu_id

    case msg.from.id do
      ^id ->
        {num, rarity} = draw
        :rand.seed(:exs1024, {num, 0, 0})

        tags = case rarity do
          "⭐️⭐️⭐️⭐️" -> "rating:e+order:portrait+order:rank+-comic+-chat_log+-long_image"
          "⭐️⭐️⭐️"   -> "rating:q+order:portrait+order:rank+-comic+-chat_log+-long_image"
          "⭐️⭐️"     -> "-rating:e+order:portrait+order:rank+-comic+-chat_log+-long_image"
          "⭐️"       -> "rating:s+order:portrait+score:0+age:6mo..1y+-comic -chat_log+-highres"
        end

        request_url = "https://danbooru.donmai.us/posts.json?limit=50&page=1&random=true&tags=#{tags}"
        request_auth = [hackney: [basic_auth: {
          Application.get_env(:telegram_bot, :danbooru_login),
          Application.get_env(:telegram_bot, :danbooru_api_key)
        }]]

        request = request_url |> HTTPoison.get!(%{}, request_auth)
        
        result = 
          Poison.Parser.parse!((request.body), keys: :atoms) 
          |> Enum.random

        image_url = if URI.parse(result.file_url).host do
          result.file_url
        else
          "http://danbooru.donmai.us#{result.file_url}"
        end

        file = download image_url

        post_id = Integer.to_string(result.id)
        artist =
          result.tag_string_artist
          |> String.split("_")
          |> Enum.join(" ")
        character_tags = result.tag_string_character |> String.split
        copyright_tags = result.tag_string_copyright |> String.split

        character_tags_cleaned = for tag <- character_tags do
          tag
          |> String.split("_(")
          |> List.first
          |> titlecase("_")
        end

        copyright = 
          copyright_tags 
          |> List.first
          |> titlecase("_")

        characters = case length(character_tags_cleaned) do
          1 -> character_tags_cleaned |> List.first
          2 -> character_tags_cleaned |> Enum.join(" and ")
          _ -> [
                character_tags_cleaned
                |> Enum.drop(-1)
                |> Enum.join(", "), 
                List.last(character_tags_cleaned)
              ]
              |> Enum.join(", and ")
        end

        caption_string = case characters do
          ", and " -> "copyright"
          _ -> "#{characters} - #{copyright}"
        end

        reply_photo_with_caption file, """
          #{rarity}
          ##{num}

          *#{caption_string}*
          [Drawn by #{artist}](https://danbooru.donmai.us/posts/#{post_id})
          """

        File.rm file
      _ ->
        reply "I'm not allowed to talk to strangers, nya."
        rekyuu "@#{msg.from.username} tried talking to me just nyow."
    end
  end
end
