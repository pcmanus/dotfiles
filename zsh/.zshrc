ANTIDOTE_HOME="$HOME/.local/share/antidote"
if [[ ! -f "$ANTIDOTE_HOME/antidote.zsh" ]]; then
  command mkdir -p "${ANTIDOTE_HOME:h}"
  command git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME" && \
    print -P "%F{33} %F{34}Antidote installed.%f%b" || \
    print -P "%F{160} Antidote install failed.%f%b"
fi

if [[ -f "$ANTIDOTE_HOME/antidote.zsh" ]]; then
  source "$ANTIDOTE_HOME/antidote.zsh"
  zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins"
  if [[ ! -f "${zsh_plugins}.txt" ]]; then
    cat >| "${zsh_plugins}.txt" <<'EOF'
zsh-users/zsh-completions path:src kind:fpath
zsh-users/zsh-autosuggestions
zdharma-continuum/fast-syntax-highlighting
EOF
  fi
  if [[ ! -s "${zsh_plugins}.zsh" || ! "${zsh_plugins}.zsh" -nt "${zsh_plugins}.txt" ]]; then
    antidote bundle <"${zsh_plugins}.txt" >| "${zsh_plugins}.zsh"
  fi
  source "${zsh_plugins}.zsh"
else
  print -P "%F{160} Antidote not available, plugins not loaded.%f%b"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi


# Options
setopt nobeep         # silence please
[[ -t 0 ]] && stty stop undef  # Disable ctrl-s terminal flow control in interactive sessions.
setopt noflowcontrol
unsetopt bgnice      # Avoid sandbox/CI warnings when tools spawn background jobs.
setopt extendedglob   # Extend ~, # and ^


export HISTFILE=~/.zsh_history
export SAVEHIST=10000
export HISTSIZE=12000

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
setopt inc_append_history     # Appends every command to the history file once it is executed


# Case insensitive completions
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'
zstyle ':completion:*' menu select  # highlight choice when doing menu completion

# This allows completion to fall back on file completion when nothing else matches
zstyle :completion::::: completer _complete _files
autoload -Uz compinit && compinit -C

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

zle_highlight=('paste:none')

autoload zmv

# Aliases

alias ls='eza -F --group-directories-first'
alias ll='eza -F --group-directories-first -l --icons --git'
alias reload_kitty='kill -SIGUSR1 $(pgrep kitty)'
alias icat='kitten icat'
alias vim='nvim'
# The space ensures alias expands after sudo
alias sudo='sudo '


export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=~/.bin/ghostty

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# i = smart cases in searches
# F = exit immediately if fit on screen
# R = AINSI color support
# X = suppress alternate screen
export LESS=iFRX

# Replace `find` by `fd` for fzf
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export PATH="$HOME/.bin:$HOME/.local/share/soar/bin:$HOME/go/bin:$PATH"

if command -v dircolors >/dev/null 2>&1 && [[ -e ~/.dircolors ]]; then
  eval "$(dircolors -b ~/.dircolors)"
fi

# Keybindings
bindkey -v  # vi mode

bindkey "^p" up-line-or-beginning-search
bindkey "^n" down-line-or-beginning-search

bindkey "^f" autosuggest-accept
 
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line


[ -f ~/.fzf-git.sh ] && source ~/.fzf-git.sh
[ -f ~/.priv.zsh ] && source ~/.priv.zsh

export CASSANDRA_USE_JDK11=true
export JAVA11_HOME=/home/pcmanus/.sdkman/candidates/java/11.0.21-tem

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

export KUBECONFIG=kube.yaml

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[[ -s "$HOME/Git/cloud-ondemand/support-tools/kube/zhrc.sh" ]] && source "$HOME/Git/cloud-ondemand/support-tools/kube/zhrc.sh"

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
