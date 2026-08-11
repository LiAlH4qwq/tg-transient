{
  config,
  bun2nix,
  lib,
  pkgs,
  ...
}:
bun2nix.mkDerivation (final: {
  src = ./.;
  packageJson = ./package.json;
  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };
  bunCompileToBytecode = false;

  passthru.wrap =
    {
      tokenFile,
      chatFile ? null,
    }:
    pkgs.writers.writeFishBin "${final.pname}-wrapped" (
      let
        cat = "cat" |> lib.getExe' pkgs.uutils-coreutils-noprefix;
        catShArg = cat |> lib.escapeShellArg;
        self = config.packages.tg-transient |> lib.getExe;
        selfShArg = self |> lib.escapeShellArg;
        tokenFileShArg = tokenFile |> lib.escapeShellArg;
        chatFileShArg = chatFile |> lib.escapeShellArg;
      in
      ''
        set -x TG_TRANSIENT_TOKEN (${catShArg} ${tokenFileShArg})
        ${selfShArg}${if chatFile == null then " " else " -c (${catShArg} ${chatFileShArg}) "}$argv
      ''
    );
})
