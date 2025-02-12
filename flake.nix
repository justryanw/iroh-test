{
  nixConfig = {
    # Replace with your own cachix or binary cache server.
    extra-trusted-public-keys = "justryanw.cachix.org-1:oan1YuatPBqGNFEflzCmB+iwLPtzq1S1LivN3hUzu60=";
    extra-substituters = "https://justryanw.cachix.org";
    allow-import-from-derivation = true;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flake-parts, crate2nix, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          system,
          pkgs,
          lib,
          ...
        }:
        let
          name = "rust-flake-template";

          systemDeps = builtins.attrValues {
            inherit (pkgs)
              # Add any system dependancies here
              ;
          };

          cargoNix =
            pkgs.callPackage
              (crate2nix.tools.${system}.generatedCargoNix {
                inherit name;
                src = ./.;
              })
              {
                defaultCrateOverrides = pkgs.defaultCrateOverrides // {
                  # Wrap root crate so any system dependancies added are available at runtime
                  ${name} = attrs: {
                    name = "${name}-${attrs.version}";

                    nativeBuildInputs = [ pkgs.makeWrapper ];

                    postInstall = ''
                      wrapProgram $out/bin/${name} \
                        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath systemDeps}
                    '';
                  };

                  # Provide system dependencies per crate during build

                  # wayland-sys = atts: {
                  #   nativeBuildInputs = with pkgs; [ pkg-config ];
                  #   buildInputs = with pkgs; [ wayland ];
                  # };
                };
              };
        in
        {
          packages = {
            default = cargoNix.rootCrate.build;
          };

          devShells.default = pkgs.mkShell {
            buildInputs =
              systemDeps
              ++ builtins.attrValues {
                inherit (pkgs)
                  cargo
                  rustc
                  pkg-config
                  rustfmt
                  cargo-watch
                  nix-output-monitor
                  ;
              };

            RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
            LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath systemDeps}";
          };
        };
    };
}
