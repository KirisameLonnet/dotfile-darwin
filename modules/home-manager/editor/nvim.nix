{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    settings = {
      number = true; 
      wrap = true;
      termguicolors = true; 
    };
    extraConfig = ''
      set number
      set wrap
      set termguicolors
      " 主题和颜色方案
      highlight Normal guibg=NONE
      highlight NonText guibg=NONE
      " colorscheme tokyonight-night
    '';
    # ... 其他插件和配置 ...
  };
}