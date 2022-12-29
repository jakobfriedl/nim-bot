import 
    dimscord, asyncdispatch, options,
    strutils, random, times

let token = readFile("./.env").strip()

let discord = newDiscordClient(token)

proc onReady(s: Shard, r: Ready) {.event(discord).} =
    echo "Ready as: " & $r.user

type 
    Action = enum
        None,
        Mute,
        Slap,

    Answer = object
        title: string
        desc: string
        image: string
        color: int
        action: Action

const badriggAnswers: seq[Answer] = @[
    Answer(
        title: "Ja",
        image: "https://i.postimg.cc/G4sJdj3N/wochenende.png",
        color: 0x00aa00
    ),
    Answer(
        title: "Nein",
        image: "https://i.postimg.cc/kBHF0HCK/depririgg.png",
        color: 0xaa0000
    ),
    Answer(
        title: "Vielleicht",
        image: "https://i.postimg.cc/bGc0J2sv/ebiroller.png",
        color: 0xaaaa00
    ),
    Answer(
        title: "Gusch",
        desc: "Hoid di goschn",
        color: 0x000aaa,
        action: Mute
    )
]

# Simple command using Nim (Ping command which edits and replies with the bot latency)
proc messageCreate(s: Shard, m: Message) {.event(discord).} =
    # check if the message-author is a bot
    if m.author.bot: return

    if m.content.toLowerAscii.startsWith("magischer badrigg"):

        let answer = sample(badriggAnswers)

        if answer.action == Mute: 
            let member = await discord.api.getGuildMember(m.guild_id.get, m.author.id)
            echo member.user.id
            echo member.user.username
            echo member.roles
        
        discard await discord.api.sendMessage(
            m.channel_id,
            embeds = @[Embed(
                title: some answer.title, 
                description: some answer.desc,
                image: some EmbedImage(url: answer.image),
                color: some answer.color
            )]
        )

waitFor discord.startSession()