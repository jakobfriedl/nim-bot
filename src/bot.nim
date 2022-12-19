import 
    dimscord, asyncdispatch,
    strutils

let token = readFile("./.env").strip()

let discord = newDiscordClient(token)

proc onReady(s: Shard, r: Ready) {.event(discord).} =
    echo "Ready as: " & $r.user

    

waitFor discord.startSession()