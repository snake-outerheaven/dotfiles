# ~/.config/fish/config.fish
# Fish shell configuration

# ---------------------------------------------------------------------------
# General settings
# ---------------------------------------------------------------------------
set -g fish_greeting ""                 # disable default greeting
set -gx EDITOR vim                     # default editor
set -gx VISUAL vim
set -gx LANG pt_BR.UTF-8
set -gx TERM xterm-256color

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
fish_add_path /usr/local/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
fish_add_path $HOME/go/bin
fish_add_path $HOME/.cargo/bin

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias ..="cd .."
alias ...="cd ../.."
alias c="clear"
alias grep="grep --color=auto"

# ---------------------------------------------------------------------------
# Abbreviations (expand as you type, fish-specific and preferred over aliases)
# ---------------------------------------------------------------------------
abbr --add gco git checkout
abbr --add gcb git checkout -b
abbr --add gst git stash
abbr --add dc docker compose
abbr --add k kubectl

# ---------------------------------------------------------------------------
# Environment variables
# ---------------------------------------------------------------------------
set -gx GOPATH $HOME/go
set -gx PNPM_HOME $HOME/.local/share/pnpm
fish_add_path $PNPM_HOME

# ---------------------------------------------------------------------------
# Prompt
# ---------------------------------------------------------------------------
# If using a prompt framework like Starship, uncomment:
# starship init fish | source

# ---------------------------------------------------------------------------
# Plugins (if using Fisher)
# ---------------------------------------------------------------------------
# fisher install jorgebucaran/nvm.fish
# fisher install PatrickF1/fzf.fish

# ---------------------------------------------------------------------------
# Key bindings
# ---------------------------------------------------------------------------

fish_vi_key_bindings   # comment out to use default (emacs-style) bindings

# ---------------------------------------------------------------------------
# Conditional / machine-specific overrides
# ---------------------------------------------------------------------------
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
