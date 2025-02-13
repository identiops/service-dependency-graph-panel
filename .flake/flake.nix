# File syntax: https://nixos.org/manual/nixos/stable/#sec-nix-syntax-summary
{
  description = "Dependencies";

  # inputs.nixpkgs_old.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.nixpkgs_unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nixpkgs_unstable,
    # nixpkgs_old,
    flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.extend overlays;
        unstable = nixpkgs_unstable.legacyPackages.${system};
        # old = (import nixpkgs_old {
        #   inherit system;
        #   config = { permittedInsecurePackages = [ "nodejs-16.20.2" ]; };
        # });
        overlays = (final: prev: {
          nodePackages =
            prev.nodePackages.override { nodejs = pkgs.nodejs_20; };
        });
        my-python-packages = python-packages:
          with python-packages;
          [
            # pyyaml # YAML module
          ];
        python-with-my-packages = pkgs.python3.withPackages my-python-packages;
        allOsPackages = with pkgs; [
          # Nix packages: https://search.nixos.org/packages
          # deno # JS interpreter https://deno.land/
          bashInteractive # bash used in scripts
          curl # HTTP and more CLI https://curl.se/
          gh # GitHub CLI https://cli.github.com/
          git-cliff # Changelog generator https://github.com/orhun/git-cliff
          just # Simple make replacement https://just.systems/
          # old.nodejs_16 # node used for husky installation https://nodejs.org/en/
          nodejs_20
          nodePackages.pnpm
          unstable.nushell # Nu Shell https://www.nushell.sh/
          python-with-my-packages
        ];
        linuxOnlyPackages = [ ];
      in {
        devShell = pkgs.mkShell {
          nativeBuildInputs = if pkgs.system == "x86_64-linux" then
            allOsPackages ++ linuxOnlyPackages
          else
            allOsPackages;
          buildInputs = [ ];
        };

      });
}
