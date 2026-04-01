{ CHaP, indexState, pkgs, ... }:

let
  indexTool = { index-state = indexState; };
  shell = { pkgs, ... }: {
    tools = {
      cabal = indexTool;
      cabal-fmt = indexTool;
      fourmolu = indexTool;
      hlint = indexTool;
    };
    buildInputs = [
      pkgs.just
      pkgs.nixfmt-classic
    ];
    shellHook = ''
      echo "Entering DPP dev shell" >&2
    '';
  };

  mkProject = ctx@{ lib, pkgs, ... }: {
    name = "dpp";
    src = ./..;
    compiler-nix-name = "ghc984";
    index-state = indexState;
    shell = shell { inherit pkgs; };
    inputMap = { "https://chap.intersectmbo.org/" = CHaP; };
  };

  project = pkgs.haskell-nix.cabalProject' mkProject;

in {
  devShells.default = project.shell;
  inherit project;
  packages.dpp-lib =
    project.hsPkgs.dpp.components.library;
  packages.dpp-tests =
    project.hsPkgs.dpp.components.tests.dpp-tests;
  packages.dpp-test-vectors =
    project.hsPkgs.dpp.components.exes.dpp-test-vectors;
}
