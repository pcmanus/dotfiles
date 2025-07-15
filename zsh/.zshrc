if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light-mode for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship


# Options
setopt nobeep         # silence please
stty stop undef       # Disable ctrl-s to freeze terminal.
setopt noflowcontrol  # Possibly the same thing?
setopt extendedglob   # Extend ~, # and ^
setopt nomatch        # Show errors when a pattern has no match


export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
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


export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=alacritty

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#export NVM_DIR=~/.nvm
#[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
#[ -s "/opt/homebrew/opt/nvm/etc/bash_completion" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion"

# i = smart cases in searches
# F = exit immediately if fit on screen
# R = AINSI color support
# X = suppress alternate screen
export LESS=iFRX

# Replace `find` by `fd` for fzf
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

#export JAVA_HOME=/opt/homebrew/Cellar/openjdk/19.0.1
#export PATH="/opt/homebrew/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:$HOME/.bin:$PATH"
#export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:$MANPATH"
export PATH="$HOME/.bin:$HOME/.local/share/soar/bin:$PATH"

test -e ~/.dircolors && eval `dircolors -b ~/.dircolors`

# Keybindings
bindkey -v  # vi mode

bindkey "^p" up-line-or-beginning-search
bindkey "^n" down-line-or-beginning-search

bindkey "^f" autosuggest-accept
 
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line


#eval "$(/opt/homebrew/bin/brew shellenv)"
#source <(kubectl completion zsh)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# The next line updates PATH and enable command completion for the Google Cloud SDK.
#if [ -f '/Users/pcmanus/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/pcmanus/google-cloud-sdk/path.zsh.inc'; fi
#if [ -f '/Users/pcmanus/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/pcmanus/google-cloud-sdk/completion.zsh.inc'; fi

[ -f ~/.priv.zsh ] && source ~/.priv.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export CASSANDRA_USE_JDK11=true
export JAVA11_HOME=/home/pcmanus/.sdkman/candidates/java/11.0.21-tem

#(cat /home/pcmanus/.cache/wal/sequences &)

# The next line updates PATH for the Google Cloud SDK.
#if [ -f '/home/pcmanus/.bin/google-cloud-sdk/path.zsh.inc' ]; then . '/home/pcmanus/.bin/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
#if [ -f '/home/pcmanus/.bin/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/pcmanus/.bin/google-cloud-sdk/completion.zsh.inc'; fi

export KUBECONFIG=kube.yaml

# Avoids having cndb trying to query k8 (and failing) when running locally (integration tests, or storage service mocked mode)
export CNDB_REGION_NAME="default"
export CNDB_ZONE_NAME="default"

eval "$(zoxide init --cmd cd zsh)"

#source "/home/pcmanus/Git/cloud-ondemand/support-tools/kube/zhrc.sh"
