{ lib, ... }:

{
  config,
  self,
  root,
  path,
  force ? true,
}:

let
  sendOut = config.lib.file.mkOutOfStoreSymlink;
  src = path |> toString |> lib.removePrefix "${self}/";
in

{
  ${baseNameOf path} = {
    inherit force;
    source = sendOut "${config.home.homeDirectory}/${root}/${src}";
  };
}
