{
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        withSystem,
        ...
      }:
      {
        systems = import inputs.systems;
        flake.overlays = {
          tg-transient =
            final: prev:
            withSystem prev.stdenv.hostPlatform.system (
              { config, ... }: {
                tg-transient = config.packages.tg-transient;
              }
            );
          default = config.flake.overlays.tg-transient;
        };
        perSystem =
          {
            config,
            inputs',
            pkgs,
            ...
          }:
          {
            packages = {
              tg-transient = pkgs.callPackage ./package.nix {
                inherit config;
              };
              default = config.packages.tg-transient;
            };
            treefmt.programs.nixfmt.enable = true;
          };
        imports = [ inputs.treefmt-nix.flakeModule ];
      }
    );
  nixConfig = {
    extra-experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operator"
      "pipe-operators"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
