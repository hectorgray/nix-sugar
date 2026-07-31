{
  description = "Miscellaneous Nix expressions";
  inputs.nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

  outputs = { nixpkgs-lib, ... }: let
    inherit (nixpkgs-lib) lib;
    importDir = (import ./lib/importDir.nix { inherit lib; }).flake.lib.importDir;
  in {
    flakeModules.lib = ./flakeModules/lib.nix;

    lib = (lib.evalModules {
      modules = [ ./flakeModules/lib.nix ] ++ importDir ./lib;
    }).config.flake.lib;
  };
}
