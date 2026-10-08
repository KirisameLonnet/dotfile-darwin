# Development Tools Package Configuration
{ config, pkgs, ... }:

let
  # XeLaTeX toolchain for Chinese documents and the local resume template.
  latexToolchain = pkgs.texlive.withPackages (ps: with ps; [
    scheme-small
    latexmk
    chktex
    xetex
    xltxtra
    xifthen
    ifmtarg
    fontspec
    xecjk
    geometry
    hyperref
    url
    enumitem
    titlesec
    nth
    tabu
    multirow
    progressbar
    setspace
    cite
    graphics
    tools
  ]);

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
    latexToolchain     # XeLaTeX + Chinese document and resume dependencies

    # ===== EMBEDDED DEVELOPMENT =====
    arduino-cli # Arduino board manager, compiler frontend, and uploader
    arduino-language-server # Arduino-aware language server for Vim and VS Code
    avrdude # AVR programmer and uploader
    picocom # Serial terminal
    clang-tools # clangd backend used for C/C++ completion

    # ===== CODE QUALITY =====
    nil                # Nix language server
    nixpkgs-fmt        # Nix formatter
    tokei              # Code statistics

    # ===== TEXT EDITORS =====
    # neovim is configured via programs.neovim in ../editor/nvim.nix
    vim                # Classic vim (compatibility)
    # VS Code 走 Homebrew cask，不在这里——它的扩展要原地改写 app bundle，
    # 与只读的 /nix/store 正面冲突。理由见 README §4.14。

    # ===== DATABASE TOOLS =====
    sqlite             # SQLite database

    # ===== KUBERNETES =====
    # 实验室 GPU 集群（五节点 k3s v1.36）的日常操作，见 myNetworkDocs/k3s-user-guide.md
    kubectl            # Kubernetes CLI
    kubernetes-helm    # Helm chart 包管理
    k9s                # 终端 UI，比 kubectl get 循环好用
    kubectx            # 快速切换 context / namespace（含 kubens）
    stern              # 跨多个 Pod 同时跟日志

    # ===== CONTAINERS =====
    # 没有 Docker Desktop：daemon 跑在 colima 拉起的 Linux 虚拟机里。
    # 这里只装二进制；开机自启的 launchd agent 和 CLI 插件链接在
    # ../development.nix，VM 规格与运行时状态不归 Nix 管，见 README §4.12。
    colima             # Linux VM（内含 lima/qemu/krunkit），docker daemon 的宿主
    docker-client      # docker CLI（仅客户端，不含 daemon）
    docker-compose     # compose v2
    docker-buildx      # buildx
    lazydocker         # 终端 UI，比 docker ps 循环好用

    # ===== CONFIG MANAGEMENT =====
    # nixpkgs 的 ansible 就是 ansible-core（不含社区 collections，需要时用
    # ansible-galaxy 装到 ~/.ansible/collections，store 外随装随用）；
    # 要锁旧版本可用 ansible_2_18 / ansible_2_19 等 attr。
    ansible           # 服务器批量配置管理与运维

    # ===== 平台 CLI =====
    # 飞书/Lark 开放平台官方 CLI（github.com/larksuite/cli），二进制名 lark-cli。
    # nixpkgs 里另有第三方的 feishu-cli（riba2534/feishu-cli），不是同一个东西。
    lark-cli           # 飞书开放平台应用脚手架 / 调试 / 发布

    # ===== JAVASCRIPT =====
    # nodejs_22 本身在 ../packages/ai.nix（它最初是为 AI CLI 装的），这里只补
    # 包管理器。pnpm 自带 nodejs-slim 作为**自己的**运行时，项目代码和生命周期
    # 脚本仍然跑在 PATH 上的 nodejs_22。
    pnpm               # pnpm + pnpx（全局安装目录见 ../shell.nix 的 PNPM_HOME）

    # ===== PROGRAMMING LANGUAGES =====
    rustToolchain      # Rust compiler + cargo + rustfmt (with std sources for rust-analyzer)
    rust-analyzer      # Rust language server
    go                 # Go programming language

  ];
}
