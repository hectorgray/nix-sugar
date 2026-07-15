{
  description = "Miscellaneous Nix helpers";
  inputs.nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

  outputs = { nixpkgs-lib, ... }: {
    flakeModules.lib = ./flakeModules/lib.nix;

    lib = {
      importDir = import ./lib/importDir.nix { inherit (nixpkgs-lib) lib; };
      xdgSendOut = import ./lib/xdgSendOut.nix;
    };
  };
}
