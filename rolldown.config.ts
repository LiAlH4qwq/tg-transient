import { defineConfig } from "rolldown"

export default defineConfig({
    input: "src/index.ts",
    output: {
        file: "dist/index.js",
        // It will break network requests in Effect.tryPromise, strange :(
        // minify: true,
    },
    platform:"node",
    external: /^node:/
})
