import { Bot } from "grammy"

const main = async (args: string[]) => {
    const token = process.env["TG_TRANSIENT_TOKEN"]
    if (token === undefined) {
        console.error("No bot token!")
        process.exit(1)
    }
    if (args.length !== 2) {
        console.error("Arg mismatch!")
        process.exit(1)
    }
    const chat = args[0]!
    const msg = args[1]!
    const bot = new Bot(token)
    await bot.api.sendMessage(chat, msg)
    console.log("Success")
    await bot.stop()
    process.exit()
}

if (import.meta.main) main(process.argv.slice(2))
