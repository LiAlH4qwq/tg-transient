import { BunRuntime, BunServices } from "@effect/platform-bun"
import { Data, Effect } from "effect"
import { Argument, Command, Flag } from "effect/unstable/cli"
import { Bot } from "grammy"

class EnvNotFoundError extends Data.TaggedError("EnvNotFoundError")<{
    name: string
}> {}

const getEnv = (name: string) =>
    Effect.sync(() => process.env[name]).pipe(
        Effect.filterOrFail(
            e => e !== undefined,
            _ => new EnvNotFoundError({ name }),
        ),
    )

const acquireBot = (token: string) => Effect.sync(() => new Bot(token))
const releaseBot = (bot: Bot) => Effect.promise(_ => bot.stop())
const getBot = (token: string) =>
    Effect.acquireRelease(acquireBot(token), releaseBot)
const sendMsg = (bot: Bot, chat: string, msg: string) =>
    Effect.tryPromise(_ => bot.api.sendMessage(chat, msg))

const chatFlag = Flag.string("chat").pipe(Flag.withAlias("c"))
const msgArg = Argument.string("message").pipe(Argument.atLeast(1))

const cmd = Command.make("tg-transient", {
    chatFlag,
    msgArg,
}).pipe(
    Command.withHandler(({ chatFlag, msgArg }) =>
        Effect.scoped(
            Effect.gen(function* () {
                const token = yield* getEnv("TG_TRANSIENT_TOKEN")
                const msg = msgArg.join("\n")
                const bot = yield* getBot(token)
                yield* sendMsg(bot, chatFlag, msg)
            }),
        ),
    ),
)

cmd.pipe(
    Command.run({ version: "0.1.0" }),
    Effect.provide(BunServices.layer),
    BunRuntime.runMain,
)
