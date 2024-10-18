{
  description = "A devShell example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rust-bin-tc =
          pkgs.rust-bin.fromRustupToolchainFile
            ./rust-toolchain.toml;

      in
      {
        devShells.default = pkgs.mkShell {

          buildInputs = [
            pkgs.openssl
            pkgs.pkg-config
            pkgs.eza
            pkgs.fd
            pkgs.probe-rs-tools
            rust-bin-tc
          ];

          shellHook = ''
            alias ls=eza
            alias find=fd
          '';
        };
      }
    );
}

# Note: For probe-rs to work without root privileges, udev rules must be applied, see
# https://probe.rs/docs/getting-started/probe-setup/#linux%3A-udev-rules. These rules can be found
# on the probe-rs website. Also ensure that these rules are written to a file in /etc/udev/rules.d/
# which is lexically before 73-seat-late.rules, otherwise they are not applied correctly, see
# https://github.com/systemd/systemd/issues/4288#issuecomment-348166161. For NixOs specifically,
# this means that the udev rules cannot be added via services.udev.extraRules, but must be added via
# services.udev.packages. Here is an example of the how to create such a derivation:
# https://discourse.nixos.org/t/creating-a-custom-udev-rule/14569.

