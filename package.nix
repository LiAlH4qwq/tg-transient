{ bun2nix, ... }:
bun2nix.mkDerivation {
  src = ./.;
  packageJson = ./package.json;
  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };
}
