defmodule TelegramBot.Util do
  require Logger

  def tmp_dir, do: Application.app_dir(:telegram_bot) <> "/tmp"

  def rekyuu_id,    do: Application.get_env(:telegram_bot, :rekyuu)
  def rekyuu(msg),  do: Nadia.send_message(rekyuu_id, msg, [parse_mode: "Markdown"])

  def titlecase(title, mod) do
    words = title |> String.split(mod)

    for word <- words do
      word |> String.capitalize
    end |> Enum.join(" ")
  end

  def download(url) do
    filename = url |> String.split("/") |> List.last
    filepath = "#{tmp_dir}/#{filename}"

    Logger.log :info, "Downloading #{filename}..."
    image = url |> HTTPoison.get!
    File.write filepath, image.body

    filepath
  end

  def draw do
    number = Enum.random(1..1_000_000)

    rarity = cond do
      number <=       320 -> "⭐️"
      number <=    59_680 -> "⭐️⭐️⭐️⭐️"
      number <=   150_000 -> "⭐️⭐️⭐️"
      number <= 1_000_000 -> "⭐️⭐️"
    end

    {number, rarity}
  end
end
