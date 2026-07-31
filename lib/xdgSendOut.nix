{ lib, ... }:

{
  flake.lib.xdgSendOut = {
    self,
    config,
    force ? true,
    flakeRoot,
    paths,
  }: let
    mkEntry = path: let
      src = path
        |> toString
        |> lib.removePrefix "${self}/";
    in lib.nameValuePair (baseNameOf path) {
      inherit force;
      source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/${src}";
    };
  in paths
    |> map mkEntry
    |> lib.listToAttrs;
}
