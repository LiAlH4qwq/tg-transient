{
  config,
  fetchPnpmDeps,
  lib,
  makeWrapper,
  nodejs,
  pkgs,
  pnpm_11,
  pnpmBuildHook,
  pnpmConfigHook,
  stdenv,
  ...
}:
stdenv.mkDerivation (
  finalAttrs:
  let
    pnpm = pnpm_11;
    packageJson = builtins.fromJSON <| builtins.readFile <| ./package.json;
  in
  {
    inherit (packageJson) version;
    pname = packageJson.name;

    src = ./.;

    nativeBuildInputs = [
      makeWrapper
      nodejs
      pnpm
      pnpmBuildHook
      pnpmConfigHook
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit pnpm;
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-d4jiO7wkDstFg+89nXrfoK/zIa+B8M6iBk0h/tNwos4=";
    };

    installPhase =
      let
        pnameShArg = finalAttrs.pname |> lib.escapeShellArg;
      in
      ''
        runHook preInstall

        mkdir -p "$out/bin" "$out/share/"${pnameShArg}
        cp 'dist/index.js' "$out/share/"${pnameShArg}'/index.js'
        makeWrapper ${nodejs |> lib.getExe |> lib.escapeShellArg} "$out/bin/"${pnameShArg} \
          --add-flags '--' \
          --add-flags "$out/share/"${pnameShArg}'/index.js'

        runHook postInstall
      '';

    passthru.wrap =
      {
        tokenFile ? null,
        chatFile ? null,
      }:
      pkgs.writers.writeFishBin "${finalAttrs.pname}-wrapped" (
        let
          cat = "cat" |> lib.getExe' pkgs.uutils-coreutils-noprefix;
          catShArg = cat |> lib.escapeShellArg;
          self = config.packages.tg-transient |> lib.getExe;
          selfShArg = self |> lib.escapeShellArg;
          tokenFileShArg = tokenFile |> lib.escapeShellArg;
          chatFileShArg = chatFile |> lib.escapeShellArg;
        in
        ''
          ${
            if chatFile == null then "" else "set -x TG_TRANSIENT_TOKEN (${catShArg} ${tokenFileShArg})\n"
          }${selfShArg}${if chatFile == null then " " else " -c (${catShArg} ${chatFileShArg}) "}$argv
        ''
      );
  }
)
