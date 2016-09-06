defmodule TelegramBot.Util do
  require Logger

  def tmp_dir, do: Application.app_dir(:telegram_bot) <> "/tmp"

  def rekyuu_id,    do: Application.get_env(:telegram_bot, :rekyuu)
  def rekyuu(msg),  do: Nadia.send_message(rekyuu_id, msg)

  def download(url) do
    filename = url |> String.split("/") |> List.last
    filepath = "#{tmp_dir}/#{filename}"

    Logger.log :info, "Downloading #{filename}..."
    image = url |> HTTPoison.get!
    File.write filepath, image.body

    filepath
  end

  def draw do
    number = Enum.random(1..10000000)

    rarity =
      cond do
        number <=     2000 -> "NORMAL"
        number <=   300000 -> "SUPER SUPER RARE"
        number <=  1800000 -> "SUPER RARE"
        number <= 10000000 -> "RARE"
      end

    {number, rarity}
  end

  def horoscope do
    request = "http://horoscope-api.herokuapp.com/horoscope/today/Virgo" |> HTTPoison.get!
    response = Poison.Parser.parse!((request.body), keys: :atoms)

    response.horoscope
  end

  def fortune do
    request = "http://fortunecookieapi.com/v1/cookie" |> HTTPoison.get!
    [response] = Poison.Parser.parse!((request.body), keys: :atoms)

    response.fortune.message
  end

  def lotto do
    request = "http://fortunecookieapi.com/v1/cookie" |> HTTPoison.get!
    [response] = Poison.Parser.parse!((request.body), keys: :atoms)

    response.lotto.numbers
  end

  def weather do
    request = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22#{Application.get_env(:telegram_bot, :location)})&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys" |> HTTPoison.get!

    response = Poison.Parser.parse!((request.body), keys: :atoms)
    weather = response.query.results.channel.item

    %{forecast: List.first(weather.forecast), current: weather.condition}
  end

  def holiday(year, month, day) do
    request = "https://holidayapi.com/v1/holidays?country=US&year=#{year}&month=#{month}&day=#{day}&key=#{Application.get_env(:telegram_bot, :weather_api)}" |> HTTPoison.get!
    response = Poison.Parser.parse!((request.body), keys: :atoms)

    List.first(response.holidays)
  end

  def daily do
    {{y,m,d},{_,_,_}} = :calendar.local_time

    a = horoscope
    f = fortune
    h = holiday(y,m,d)
    w = weather

    opener = """
      #{Enum.random(["Ohayou", "Good morning", "Mornin", "Morning", "Hey sleepyhead"])}, nya. #{Enum.random(["Did you sleep well?", "How did you sleep?", "Get enough sleep?", "You went to bed way too late.", "Did I wake you up?", "It's time to get up!"])}
      """

    weather_holiday =
      case h do
        nil -> ""
        _   -> "It's #{h.name} today! "
      end

    temp = """
      #{weather_holiday}It's gonna get up to #{w.forecast.high}° and will be #{w.forecast.low}° tonight. It's #{w.current.temp}° and #{String.downcase w.current.text} right now, nya.
      """

    astro = """
      Here's today's horoscope, nya.

      #{a}
      """

    cookie = """
      Here's your fortune for today, nya. \"#{f}\" #{Enum.random(["That's a weird one, huh?", "That one is different.", "Who knew?", "Interesting!", "Huh, neat.", "I like this one.", "Nya ~", "Kuma will like this.", "Weird.", "Well, okay then.", "Dunno about this one.", "Oh."])}
      """

    rekyuu opener
    rekyuu temp
    rekyuu astro
    rekyuu cookie
    rekyuu "Don't forget to do your /draw today!"
  end
end
