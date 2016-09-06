defmodule TelegramBot.Commands do
  use TelegramBot.Module
  import TelegramBot.Util
  require Logger

  command ["start", "tama", "nya", "ping"] do
    Logger.log :warn, "== DEBUG =="
    Logger.log :debug, "msg.chat.id: #{msg.chat.id}"
    Logger.log :debug, "msg.chat.type: #{msg.chat.type}"
    Logger.log :debug, "msg.from.username: @#{msg.from.username}"
    Logger.log :debug, "msg.text: #{msg.text}"

    id = rekyuu_id
    case msg.chat.id do
      ^id -> reply "Nya ~"
      _ ->
        reply "I'm not allowed to talk to strangers, nya."
        rekyuu "Someone strange tried talking to me just nyow."
    end
  end

  command "daily" do
    id = rekyuu_id

    case msg.chat.id do
      ^id -> daily
      _ ->
        reply "I'm not allowed to talk to strangers, nya."
        rekyuu "Someone strange tried talking to me just nyow."
    end
  end

  command "draw" do
    {num, rarity} = draw

    :random.seed(num)

    request = "http://danbooru.donmai.us/posts.json?limit=#{Enum.random(50..100)}&page=#{Enum.random(1..10)}&tags=rating:safe" |> HTTPoison.get!
    result = Poison.Parser.parse!((request.body), keys: :atoms) |> Enum.random
    file = download "http://danbooru.donmai.us#{result.file_url}"
    post_id = Integer.to_string(result.id)

    id = rekyuu_id
    case msg.chat.id do
      ^id -> reply_photo_with_caption file, "#{rarity} (#{num})\nhttps://danbooru.donmai.us/posts/#{post_id}"
      _ ->
        reply "I'm not allowed to talk to strangers, nya."
        rekyuu "Someone strange tried talking to me just nyow."
    end
  end
end
