function discord_bot_msg
  set -l DISCORD_BOT_JSON $(cat ~/.config/.secrets/DISCORD_BOT.json)
  set -l BOT_SECRET $(echo $DISCORD_BOT_JSON | jq -r .bot_secret)
  set -l BOT_GUILD $(echo $DISCORD_BOT_JSON | jq -r .guild_id)
  set -l BOT_ALERT_CHANNEL $(echo $DISCORD_BOT_JSON | jq -r .bot_reminder_channel)

  ami-go -t $BOT_SECRET -guild $BOT_GUILD -channel $BOT_ALERT_CHANNEL -command msg -message $argv
  
end
