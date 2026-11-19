# Nix Sugar

Personal collection of Nix expressions I use across projects or would rather
abstract away from individual configurations. Some are based on existing work
(linked where relevant, check them out!) but adapted to my preferred
scope/style.

## Requirements

Ensure the following are enabled in your Nix configuration:

```nix
nix.settings.experimental-features = [
  "flakes"
  "nix-command"
  "pipe-operators"
];
```

Then add to your inputs:

```nix
inputs.sugar = {
  url = "github:hectorgray/nix-sugar";

  # Optional
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-parts.follows = "flake-parts";
};
```

## Functions

### `listTree`

```
listTree :: Path -> [String]
```

Recursively list all `.nix` files under a directory, skipping `flake.nix` and
paths prefixed with `.` or `_`.

#### Example

```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  systems = [ "x86_64-linux" ];
  imports = inputs.sugar.lib.listTree ./.;
};
```

**Related:**

- [denful/import-tree](https://github.com/denful/import-tree)

## Flake Modules

These modules require [Flake Parts](https://github.com/hercules-ci/flake-parts).

### `vendor`

```nix
imports = [ inputs.sugar.flakeModules.vendor ];
```

Copy files and directories from pinned upstream sources or derivation outputs
into your project. Destinations are relative to the project root, found by
searching upward from the working directory for `rootMarker` (which defaults
to `flake.nix`).

#### Example

Consider vendoring a C library for a project. We can pin a source in
`flake.nix`:

```nix
inputs.yyjson = {
  url = "github:ibireme/yyjson";
  flake = false;
};
```

Then declare the files/directories we're interested in:

```nix
{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    vendor = {
      rootMarker = ".git";

      targets = {
        "vendor/yyjson/src" = "${inputs.yyjson}/src";

        "vendor/yyjson/LICENSE" = pkgs.concatText "v-license" [
          (pkgs.writeText "v-heading" "--- `yyjson` license ---\n\n")
          "${inputs.yyjson}/LICENSE"
        ];
      };
    };
  };
}
```

#### Usage

> [!WARNING]
> `nix run .#vendor` replaces each path in `vendor.targets` with a copy of its
> source. This discards local edits and removes any extra files inside a
> directory listed as a target.

Do note that `"foo/bar.nix"` targets only that file, leaving its siblings in
`foo/` alone. Regardless, I would highly recommend that any use of this app be
paired with version control.

```sh
nix run .#vendor # refresh copies
nix flake check # check copies against declared sources
```

If your flake is in a Git repo, remember to run `git add` on the newly generated
files so `nix flake check` can see them.

**Related:**

- [mightyiam/files](https://github.com/mightyiam/files)

### `easyLib`

```nix
imports = [ inputs.sugar.flakeModules.easyLib ];
```

Merge `flake.lib` and `perSystem.lib` across modules as lazy, nested attribute
sets of functions (type-checked), without declaring individual options.
Multiple definitions at the same attribute path are an error.

#### Example

##### Definition

```nix
# gitAlias.nix
{ ... }: {
  flake.lib.gitAlias = body: "!f() {\n${body}\n}; f";
}
```

```nix
# writeDir.nix
{...}: {
  perSystem = { pkgs, ... }: let
    writeDir = format: path: value:
      pkgs.linkFarm (baseNameOf path) {
        ${path} = format.generate (baseNameOf path) value;
      };
  in {
    lib.writeDir = {
      gitIni = writeDir (pkgs.formats.gitIni {});
      toml = writeDir (pkgs.formats.toml {});
    };
  };
}
```

##### Call

Assuming `gitAlias` is our own and `writeDir` is defined in an external flake
named `extra-writers`:

```nix
{ self, withSystem, ... }: {
  flake.homeModules.example = { pkgs, ... }:
    withSystem "x86_64-linux" ({ inputs', ... }: let
      inherit (inputs'.extra-writers.lib) writeDir;
    in {
      home.packages = [ pkgs.git ];

      xdg.configFile.git.source = writeDir.gitIni "config" {
        alias.churn20 = self.lib.gitAlias /*bash*/ ''
          git log --format= --name-only "$@" |
            sed '/^$/d' |
            sort |
            uniq -c |
            sort -nr |
            head -20
        '';
      };
    });
}
```

Consumers without flake-parts can access the system-specific function through
`inputs.extra-writers.lib.${system}`.

## Home Modules

These modules require [Home Manager](https://github.com/nix-community/home-manager).

### `mutableFiles`

```nix
imports = [ inputs.sugar.homeModules.mutableFiles ];
```

Install individual files from `home.file` and `xdg.*File` as writable copies.
Edits last until the next Home-Manager activation, which restores the declared
contents.

#### Example

```nix
xdg.configFile."VSCodium/User/settings.json" = {
  mutable = true;

  source = pkgs.writers.writeJSON "vscodium-settings.json" {
    "editor.tabSize" = 2;
    "workbench.startupEditor" = "newUntitledFile";
  };
};
```

**Related:**

- [piousdeer's gist](https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa)
- [`lib.hm.generators.mkImpureConfigMerger`](https://github.com/nix-community/home-manager/pull/9654)

### `outOfStore`

```nix
imports = [ (inputs.sugar.homeModules.outOfStore { inherit self; }) ];
```

Link `home.file` and `xdg.*File` entries to files outside the Nix store, so
edits take effect without rebuilding.

Set `home.flakeRoot` to your local flake directory so sources like `./nvim`
link to your working files instead of the flake's immutable copy in the store.

#### Example

```nix
home.flakeRoot = "/home/user/dotfiles";

xdg.configFile."nvim" = {
  source = ./nvim;
  outOfStore = true;
};
```
