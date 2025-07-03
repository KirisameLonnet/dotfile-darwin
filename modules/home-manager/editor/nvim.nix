{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      set number
      set wrap
      set termguicolors
      set mouse=a
      " 启用鼠标支持

      lua << EOF
      vim.o.packpath = vim.fn.stdpath('config')..'/plugins'
      vim.cmd [[packadd packer.nvim]]
      local fn = vim.fn
      local install_path = fn.stdpath('config')..'/plugins/packer/start/packer.nvim'
      local plugin_path = fn.stdpath('config')..'/plugins'
      if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
      end

      require('packer').startup({function()
        use 'nvim-treesitter/nvim-treesitter'
        use 'nvim-telescope/telescope.nvim'
        use 'nvim-lualine/lualine.nvim'
        use 'hrsh7th/nvim-cmp'
        use 'github/copilot.vim'
      end,
      config = {
        package_root = plugin_path,
      }})
      EOF

      " 配置主题
      colorscheme tokyonight-night

      " 配置状态栏
      lua require('lualine').setup()

      " 配置 Telescope
      lua require('telescope').setup()

      " 配置 Treesitter
      lua require('nvim-treesitter.configs').setup {
        highlight = {
          enable = true,
        },
      }

      " 配置 Copilot
      let g:copilot_no_tab_map = v:true
      imap <silent><script><expr> <C-Space> copilot#Accept()
    '';
    # Plugins are managed by packer.nvim automatically
    # No need to manually copy plugin files
  };

  # Plugins are managed by packer.nvim, not through home.file
  # The packer configuration above will automatically install and manage plugins
}