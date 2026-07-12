{
  description = "Miscellaneous Nix helpers";
  inputs.nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

  outputs = { nixpkgs-lib, ... }: {
    lib.importDir = import ./lib/importDir.nix { inherit (nixpkgs-lib) lib; };
  };
}
