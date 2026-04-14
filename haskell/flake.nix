{
  description = "DPP — on-chain types and test vectors for the signed readings protocol";
  nixConfig = {
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys =
      [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
  };
  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    iohkNix = {
      url = "github:input-output-hk/iohk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    CHaP = {
      url = "github:intersectmbo/cardano-haskell-packages?ref=repo";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, haskellNix
    , iohkNix, CHaP, ... }:
    let
      parts = flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [ "x86_64-linux" "aarch64-darwin" ];
        perSystem = { system, ... }:
          let
            pkgs = import nixpkgs {
              overlays = [
                iohkNix.overlays.crypto
                haskellNix.overlay
                iohkNix.overlays.haskell-nix-crypto
                iohkNix.overlays.cardano-lib
              ];
              inherit system;
            };
            project = import ./nix/project.nix {
              indexState = "2025-12-07T00:00:00Z";
              inherit CHaP pkgs;
            };
          in {
            packages = {
              inherit (project.packages)
                dpp-lib dpp-tests dpp-test-vectors;
              default = project.packages.dpp-lib;
            };
            inherit (project) devShells;
          };
      };
    in {
      inherit (parts) packages devShells;
    };
}
