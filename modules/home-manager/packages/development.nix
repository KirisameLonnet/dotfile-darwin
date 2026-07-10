# Development Tools Package Configuration
{ config, pkgs, ... }:

let
  # Build a self-contained Rust toolchain directory with bin/ + lib/ so that
  # both cargo and rust-analyzer (which sets RUSTUP_TOOLCHAIN to the sysroot
  # path) can find everything they need.  We graft the standard library
  # sources into lib/rustlib/src/ for rust-analyzer go-to-definition on std.
  rustToolchain = pkgs.runCommand "rust-toolchain-with-src" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    # -- bin/ : wrapped rustc/rustdoc + cargo, rustfmt, etc. --
    mkdir -p $out/bin
    for bin in ${pkgs.rustc.unwrapped}/bin/*; do
      makeWrapper "$bin" "$out/bin/$(basename "$bin")" \
        --add-flags "--sysroot $out"
    done
    ln -s ${pkgs.cargo}/bin/cargo   $out/bin/cargo
    ln -s ${pkgs.rustfmt}/bin/*     $out/bin/ 2>/dev/null || true

    # -- lib/ : stock libs + grafted std sources --
    mkdir -p $out/lib
    for item in ${pkgs.rustc.unwrapped}/lib/*; do
      ln -s "$item" "$out/lib/$(basename "$item")"
    done
    rm -f $out/lib/rustlib
    mkdir -p $out/lib/rustlib
    for item in ${pkgs.rustc.unwrapped}/lib/rustlib/*; do
      ln -s "$item" "$out/lib/rustlib/$(basename "$item")"
    done
    mkdir -p $out/lib/rustlib/src/rust
    ln -s ${pkgs.rustPlatform.rustLibSrc} $out/lib/rustlib/src/rust/library
  '';
in
{
  home.packages = with pkgs; [
    # ===== VERSION CONTROL =====
    git                # Version control system
    gh                 # GitHub CLI
    lazygit            # Terminal UI for git
    delta              # Better diff

    # ===== BUILD TOOLS =====
    gnumake            # Make build tool
    cmake              # Cross-platform build tool
    pkg-config         # Package configuration
    android-tools      # Android Debug Bridge (ADB)

    # ===== CODE QUALITY =====
    nil                # Nix language server
    nixpkgs-fmt        # Nix formatter
    tokei              # Code statistics

    # ===== TEXT EDITORS =====
    # neovim is configured via programs.neovim in ../editor/nvim.nix
    vim                # Classic vim (compatibility)
    vscode             # Visual Studio Code

    # ===== DATABASE TOOLS =====
    sqlite             # SQLite database

    # ===== PROGRAMMING LANGUAGES =====
    rustToolchain      # Rust compiler + cargo + rustfmt (with std sources for rust-analyzer)
    rust-analyzer      # Rust language server
    go                 # Go programming language

  ];
}
