{ config, force ? true, path }:

let
  sendOut = config.lib.file.mkOutOfStoreSymlink;
in

{
  ${baseNameOf path} = {
    inherit force;
    source = sendOut "${config.home.homeDirectory}/${path}";
  };
}
