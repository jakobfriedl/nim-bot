import 
    dimscord, dimscmd,
    asyncdispatch, options, 
    strutils, sequtils, strformat, 
    random, math,
    macros

let env = readFile("./.env").strip().splitLines()
let token = env[0]
let guild = env[1]

let discord = newDiscordClient(token)
var cmd = discord.newHandler()

type 
    Action = enum
        None,
        Mute,
        Slap,

    Answer = object
        title: string
        image: string
        color: int
        action: Action

const badriggAnswers: seq[Answer] = @[
    Answer(
        title: "Ja",
        image: "https://i.postimg.cc/G4sJdj3N/wochenende.png",
        color: 0x00aa00,
        action: None
    ),
    Answer(
        title: "Nein",
        image: "https://i.postimg.cc/kBHF0HCK/depririgg.png",
        color: 0xaa0000,
        action: None
    ),
    Answer(
        title: "Vielleicht",
        image: "https://i.postimg.cc/bGc0J2sv/ebiroller.png",
        color: 0xaaaa00,
        action: None
    ),
    Answer(
        title: "Dumme Frage",
        color: 0x000aaa,
        action: Mute
    )
]

proc reply(m: Message, msg: string): Future[Message] {.async.} = 
    return await discord.api.sendMessage(m.channel_id, msg)

proc reply(i: Interaction, msg: string) {.async.} =
    echo i
    let response = InteractionResponse(
        kind: irtChannelMessageWithSource,
        data: some InteractionApplicationCommandCallbackData(
            content: msg
        )
    )
    await discord.api.createInteractionResponse(i.id, i.token, response)

## Chat Commands
# sum [number] ... 
cmd.addChat("sum") do (nums: seq[int]): 
    discard await msg.reply($nums.sum)

# multiply [number] ...
cmd.addChat("multiply") do (nums: seq[int]): 
    discard await msg.reply($(nums.foldl(a * b)))

# random [number] [number]
cmd.addChat("random") do (min: int, max: int): 
    discard await msg.reply($(rand(min..max)))

# echo [string]
cmd.addChat("echo") do (str: seq[string]): 
    discard await msg.reply($str.join(" "))

## Slash Commands
# mute [user] [time]
cmd.addSlash("mute", guildID = guild) do (user: User, time: int): 
    ## Mute a user for a duration of time
    discard

proc onReady(s: Shard, r: Ready) {.event(discord).} =
    echo "Ready as: " & $r.user
    await cmd.registerCommands() 

proc messageCreate(s: Shard, m: Message) {.event(discord).} =
    # check if the message-author is a bot
    if m.author.bot: return

    discard await cmd.handleMessage("!", s, m)

    if m.content.toLowerAscii.join("").contains("cheg"): 
        discard m.reply("cheg 👍")

    if m.content.toLowerAscii.startsWith("magischer linuxmann"):

        let answer = sample(badriggAnswers)

        if answer.action == Mute: 
            let member = await discord.api.getGuildMember(m.guild_id.get, m.author.id)
            echo member.user.id
            echo member.user.username
            echo member.roles
        
        discard await discord.api.sendMessage(
            m.channel_id,
            embeds = @[Embed(
                title: some fmt"Q: {m.content}", 
                description: some fmt"A: {answer.title}",
                image: some EmbedImage(url: answer.image),
                color: some answer.color
            )]
        )

proc interactionCreate(s: Shard, i: Interaction) {.event(discord).} =
    discard await cmd.handleInteraction(s, i)

waitFor discord.startSession()