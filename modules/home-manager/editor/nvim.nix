{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = false;
    withRuby = false;
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil # Nix LSP
      vtsls
      pyright
      ruff
      typescript-language-server
      vscode-langservers-extracted

      # Formatters, linters, and parser tooling used by LazyVim extras
      nixfmt
      statix
      stylua
      shfmt
      tree-sitter

      # Tooling
      ripgrep
      fd
      lazygit
    ];
  };

  xdg.configFile = {
    "nvim/init.lua".text = ''
      require("config.lazy")
    '';

    "nvim/lua/config/lazy.lua".text = ''
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local out = vim.fn.system({
          "git", "clone", "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable", lazypath,
        })
        if vim.v.shell_error ~= 0 then
          vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
          }, true, {})
          return
        end
      end
      vim.opt.rtp:prepend(lazypath)

      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          -- LazyVim extras
          { import = "lazyvim.plugins.extras.lang.typescript" },
          { import = "lazyvim.plugins.extras.lang.python" },
          { import = "lazyvim.plugins.extras.lang.nix" },
          { import = "lazyvim.plugins.extras.lang.json" },
          -- User plugins
          { import = "plugins" },
        },
        defaults = { lazy = false, version = false },
        checker = { enabled = true },
        rocks = { enabled = false },
        performance = {
          rtp = {
            disabled_plugins = {
              "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
            },
          },
        },
      })
    '';

    "nvim/lua/config/options.lua".text = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"
    '';

    "nvim/lua/config/keymaps.lua".text = ''
      -- Additional keymaps (LazyVim provides sensible defaults)
    '';

    "nvim/lua/config/autocmds.lua".text = ''
      -- Additional autocmds (LazyVim provides sensible defaults)
    '';

    "nvim/lua/plugins/colorscheme.lua".text = ''
      return {
        {
          "catppuccin/nvim",
          name = "catppuccin",
          lazy = false,
          priority = 1000,
          opts = {
            transparent_background = true,
          },
        },
        {
          "LazyVim/LazyVim",
          opts = { colorscheme = "catppuccin-mocha" },
        },
      }
    '';

    "nvim/lua/plugins/nix-managed-tools.lua".text = ''
      return {
        {
          "mason-org/mason.nvim",
          opts = function(_, opts)
            opts.ensure_installed = {}
          end,
        },
        {
          "neovim/nvim-lspconfig",
          opts = {
            servers = {
              lua_ls = { mason = false },
              nil_ls = { mason = false },
              vtsls = { mason = false },
              pyright = { mason = false },
              ruff = { mason = false },
              jsonls = { mason = false },
            },
          },
        },
      }
    '';
  };
}
