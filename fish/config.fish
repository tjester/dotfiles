set -g fish_greeting

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER zen
fish_add_path -m $HOME/.local/bin

if status is-interactive
    starship init fish | source
    zoxide init fish | source
    fzf --fish | source

    # ls family -> eza
    abbr -a ls  eza --icons
    abbr -a ll  eza --icons -l
    abbr -a la  eza --icons -la
    abbr -a lt  eza --icons --tree

    abbr -a cat bat

    # git
    abbr -a gs  git status
    abbr -a ga  git add
    abbr -a gc  git commit
    abbr -a gp  git push
    abbr -a gl  git pull
    abbr -a gd  git diff
    abbr -a gco git checkout

    # hyprland
    abbr -a hreload hyprctl reload
end
