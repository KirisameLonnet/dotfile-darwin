{ config, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    settings = {
      number = true; 
      wrap = true;
      termguicolors = true; 
    };
    # 主题和颜色方案
    extraConfigLua = ''
      -- 设置背景透明，这通常依赖于你的终端模拟器支持
      vim.cmd('highlight Normal guibg=NONE')
      vim.cmd('highlight NonText guibg=NONE')
      -- 选择一个支持透明度的颜色方案，例如 "tokyonight" 或 "onedark"
      -- vim.cmd('colorscheme tokyonight-night')
    '';
    # ... 其他插件和配置 ...
  };
}