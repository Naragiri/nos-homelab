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
                      ansible
                      packer
                      just

                      # Styling and linting
                      deadnix
                      nixfmt
                      statix
                      treefmt

                      yamlfmt
                      yamllint
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

                        yamllint = {
                          enable = true;
                          settings.configuration = ''
                            extends: default
                            ignore: |
                              .pre-commit-config.yaml
                              ansible/inventory/host_vars/**/vault.yml
                            rules:
                              document-start: disable
                              truthy: disable
                              quoted-strings:
                                quote-type: double
                                required: only-when-needed
                              line-length:
                                max: 180
                          '';
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
