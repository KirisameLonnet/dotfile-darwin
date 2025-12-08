# LaTeX Configuration with Chinese and Math Support
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (texlive.combine {
      inherit (texlive) scheme-medium
        ctex          # Chinese support (essential)
        xeCJK         # Chinese support for XeLaTeX
        amsmath       # Advanced math formulas
        mathtools     # Extensions to amsmath
        
        # Additional recommended packages for typical usage
        latexmk       # Build automation
        collection-fontsrecommended
        collection-mathscience
        ;
    })
  ];
}
