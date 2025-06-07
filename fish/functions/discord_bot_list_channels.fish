function discord_bot_list_channels
ami-go -t $(cat  ~/.config/.secrets/DISCORD_BOT.json | jq -r .bot_secret) -guild $(cat ~/.config/.secrets/DISCORD_BOT.json | jq -r .guild_id) -command list
end
