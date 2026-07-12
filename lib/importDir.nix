{ lib, ... }: dir:

dir
  |> lib.filesystem.listFilesRecursive
  |> map toString
  |> builtins.filter (p: baseNameOf p != "flake.nix")
  |> builtins.filter (p: !(lib.hasInfix "/_" p))
  |> builtins.filter (p: !(lib.hasInfix "/." p))
  |> builtins.filter (p: lib.hasSuffix ".nix" p)
