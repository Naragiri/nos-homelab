{
  description = "NaraOS Homelab";

  inputs = {
    devenv.url = "github:cachix/devenv";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{
      devenv,
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      systems = [ "x86_64-linux" ];

      perSystem =
        {
          lib,
          pkgs,
          system,
          ...
        }:
        {
          devShells = {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;

              modules = [
                (
                  { pkgs, ... }:
                  {
                    packages = with pkgs; [
                      terraform
                      packer

                      # Styling and linting
                      deadnix
                      nixfmt
                      statix
                      treefmt
                    ];

                    git-hooks = {
                      hooks = {
                        deadnix = {
                          enable = true;
                          excludes = [
                            "generated.nix"
                          ];
                          settings = {
                            edit = true;
                          };
                        };
                        nixfmt = {
                          enable = true;
                          excludes = [ "generated.nix" ];
                        };
                        statix = {
                          enable = true;
                          excludes = [ "generated.nix" ];
                        };
                      };
                    };
                  }
                )
              ];
            };
          };

          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "terraform"
                "packer"
              ];
          };
        };
    });
}
