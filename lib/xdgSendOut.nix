{ lib, ... }:

{
  flake.lib.xdgSendOut = {
    config,
    self,
    flakeRoot,
    paths,
    force ? true,
  }: let
    src = path: path |> toString |> lib.removePrefix "${self}/";

    mkEntry = path: lib.nameValuePair (baseNameOf path) {
      inherit force;
      source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/${src path}";
    };
  in paths
    |> map mkEntry
    |> lib.listToAttrs;
}
