{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      # --- UI & Visuals ---
      catppuccin-nvim
      lualine-nvim
      bufferline-nvim # VSCode-like tabs
      nvim-web-devicons # Icons
      neo-tree-nvim
      nui-nvim

      # --- Intellisense & LSP ---
      nvim-lspconfig
      lspsaga-nvim # Prettier LSP UI
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path # Filesystem path completion source
      luasnip # Snippet engine
      cmp_luasnip # Snippet completion source

      # --- Syntax & Git ---
      nvim-treesitter.withAllGrammars
      gitsigns-nvim # Git integration

      # --- Utilities ---
      plenary-nvim
      telescope-nvim
      copilot-lua
      copilot-cmp
      auto-session # For session management
    ];

    extraConfig = ''
      " --- Vimscript Settings ---
      set number
      set termguicolors
      set mouse=a
      set wrap
      set signcolumn=yes " Always show the sign column for gitsigns

      let g:mapleader = ' '
      let g:maplocalleader = ' '

      " --- Lua Configuration ---
      lua << EOF
      -- ===================================================================
      -- Help Screen Function
      -- ===================================================================
      local function show_help()
        local help_content = {
          "┌──────────────────────────────────────────────────────────────┐",
          "│                      Neovim Help Screen                      │",
          "├──────────────────────────────────────────────────────────────┤",
          "│ Leader key is <Space>                                        │",
          "├──────────────────────────────────────────────────────────────┤",
          "│ File Management                                              │",
          "│   <leader>e      - Toggle file explorer (Neo-tree)           │",
          "│                                                              │",
          "│ Search (Telescope)                                           │",
          "│   <leader>ff     - Find files in project                     │",
          "│   <leader>fg     - Grep for text in project                  │",
          "│                                                              │",
          "│ Session Management                                           │",
          "│   <leader>ss     - Save current session                      │",
          "│   <leader>sr     - Restore last session                      │",
          "│                                                              │",
          "│ LSP & Code Navigation (Lspsaga)                              │",
          "│   K            - Show documentation for word under cursor    │",
          "│   <leader>ca   - Show code actions                           │",
          "│   gd           - Go to definition                            │",
          "│                                                              │",
          "│ Git Integration (Gitsigns)                                   │",
          "│   <leader>gb     - Show git blame for current line           │",
          "│                                                              │",
          "│ GitHub Copilot                                               │",
          "│   <Tab>        - (Insert Mode) Accept suggestion             │",
          "│   <leader>cc   - Open Copilot Chat                           │",
          "│                                                              │",
          "│ This Help Screen                                             │",
          "│   <leader>h      - Show this help window                     │",
          "│   q or <Esc>   - Close this window                           │",
          "└──────────────────────────────────────────────────────────────┘",
        }

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_content)

        local width = 70
        local height = #help_content
        local win_width = vim.api.nvim_get_option("columns")
        local win_height = vim.api.nvim_get_option("lines")
        local row = math.floor((win_height - height) / 2)
        local col = math.floor((win_width - width) / 2)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = 'editor',
          width = width,
          height = height,
          row = row,
          col = col,
          style = 'minimal',
        })

        vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<cr>', { noremap = true, silent = true })
      end

      -- ===================================================================
      -- Keymaps
      -- ===================================================================
      local map = vim.keymap.set
      map('n', '<leader>h', show_help, { desc = "Show Help" })
      map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = "Find Files" })
      map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = "Live Grep" })
      map('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = "Toggle File Explorer" })
      map('n', 'K', '<cmd>Lspsaga hover_doc<cr>', { desc = "Hover Documentation" })
      map('n', '<leader>ca', '<cmd>Lspsaga code_action<cr>', { desc = "Code Action" })
      map('n', 'gd', '<cmd>Lspsaga goto_definition<cr>', { desc = "Go To Definition" })
      map('n', '<leader>gb', '<cmd>Gitsigns blame_line<cr>', { desc = "Git Blame" })
      map('n', '<leader>cc', "<cmd>CopilotChat<cr>", { desc = "Copilot Chat" })

      -- Session management
      map('n', '<leader>ss', '<cmd>SessionSave<cr>', { desc = 'Save session' })
      map('n', '<leader>sr', '<cmd>SessionRestore<cr>', { desc = 'Restore session' })

      -- ===================================================================
      -- Plugin Configurations
      -- ===================================================================
      -- Theme
      vim.cmd.colorscheme "catppuccin-mocha"

      -- Auto Session (Workspace Management)
      require('auto-session').setup({
          log_level = 'error',
          auto_session_enable_last_session = true,
          auto_save_enabled = true,
          session_dir_path = vim.fn.stdpath('data') .. "/sessions/",
      })

      -- Copilot
      require("copilot").setup({
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<Tab>",
            dismiss = "<C-e>",
          },
        },
        panel = {
          auto_refresh = true,
        },
        agent = {
          enabled = true,
          chat = {
            enabled = true,
          },
        },
      })

      -- Bufferline (Tabs)
      require('bufferline').setup({
        options = {
          mode = "buffers",
          separator_style = "thin",
          show_buffer_close_icons = true,
          show_close_icon = true,
        }
      })

      -- Lualine (Statusline)
      require('lualine').setup({
        options = {
          theme = 'catppuccin',
          globalstatus = true,
        },
        sections = {
          lualine_c = {'filename', {
            name = 'gitsigns',
            symbols = {added = ' ', modified = ' ', removed = ' '},
          }},
        },
      })

      -- Gitsigns
      require('gitsigns').setup()

      -- Neo-tree (File Explorer)
      require('neo-tree').setup({
        window = { mappings = { ["<space>"] = "none" } }
      })

      -- Telescope (Fuzzy Finder)
      require('telescope').setup({})

      -- Nvim-treesitter (Syntax Highlighting)
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
      })

      -- Nvim-cmp (Autocompletion)
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require("copilot_cmp").setup() -- Setup for copilot-cmp
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'copilot' },
        }),
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        },
      })

      -- Lspsaga (LSP UI)
      require('lspsaga').setup({
        ui = {
          code_action = "", -- Lightbulb icon
        }
      })

      -- ===================================================================
      -- Comprehensive Transparency Settings
      -- ===================================================================
      local function set_transparent_bg(group, settings)
        local final_settings = { bg = "none" }
        if settings then
          for k, v in pairs(settings) do
            final_settings[k] = v
          end
        end
        vim.api.nvim_set_hl(0, group, final_settings)
      end

      -- General UI
      set_transparent_bg("Normal")
      set_transparent_bg("NormalFloat")
      set_transparent_bg("SignColumn")
      set_transparent_bg("LineNr")
      set_transparent_bg("EndOfBuffer")
      set_transparent_bg("CursorLine")
      set_transparent_bg("CursorLineNr")
      set_transparent_bg("FloatBorder")

      -- File Explorer
      set_transparent_bg("NeoTreeNormal")
      set_transparent_bg("NeoTreeNormalNC")

      -- Pop-up Menu (Completion)
      set_transparent_bg("Pmenu")
      set_transparent_bg("PmenuSel", { fg = "#c6a0f6", bold = true }) -- Highlight selection without a background
      set_transparent_bg("PmenuSbar")
      set_transparent_bg("PmenuThumb")

      -- Telescope (Fuzzy Finder)
      set_transparent_bg("TelescopeNormal")
      set_transparent_bg("TelescopeBorder")
      set_transparent_bg("TelescopePromptNormal")
      set_transparent_bg("TelescopeResultsNormal")
      set_transparent_bg("TelescopePreviewNormal")

      -- Bufferline (Tabs)
      set_transparent_bg("BufferLineBackground")
      set_transparent_bg("BufferLineFill")
      set_transparent_bg("BufferLineTab")
      set_transparent_bg("BufferLineTabSelected")
      set_transparent_bg("BufferLineTabClose")
      set_transparent_bg("BufferLineIndicatorSelected")

      -- Statusline
      set_transparent_bg("StatusLine")
      set_transparent_bg("StatusLineNC")

      -- LSP Related
      set_transparent_bg("LspsagaHoverDoc")
      EOF
    '';
  };
}
