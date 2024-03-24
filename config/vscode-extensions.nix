let
  system = builtins.currentSystem;
  extensions =
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "refs/heads/master";
      rev = "521346487f30c82f0d471eef6e5644672e25e7a3";
    })).extensions.${system};
  extensionsList = with extensions.vscode-marketplace; [
    andrsdc.base16-themes
    arrterian.nix-env-selector
    bbenoist.nix
    dotjoshjohnson.xml
    github.github-vscode-theme
    ms-python.black-formatter
    ms-python.debugpy
    ms-python.isort
    ms-python.mypy-type-checker
    ms-python.python
    ms-python.vscode-pylance
    stkb.rewrap
    tal7aouy.theme
    teabyii.ayu
    trond-snekvik.simple-rst
    liviuschera.noctis
    arcticicestudio.nord-visual-studio-code
    zhuangtongfa.material-theme
    wesbos.theme-cobalt2
  ];
in
extensionsList
