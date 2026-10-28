# ------------------------------------------------------------------------------
# Shell wrapper + completion for the `wt` Python worktree tool (~/.bin/wt).
#
# The heavy lifting (worktree creation/listing/removal and Linear integration)
# lives in the Python script ~/.bin/wt. A program in $PATH cannot change its
# parent shell's cwd, so `wt` writes the directory it wants us to move into to
# the file named by $WT_CD_FILE; this wrapper reads that file and performs the
# `cd`.
#
# Commands:
#   wt new <branch>              Create a worktree for <branch> and cd into it
#   wt create <short> <title>    Create a PLDEV Linear ticket + worktree for it
#   wt info                      Show the Linear ticket for the current worktree
#   wt jump [name]               Jump to a worktree (fzf picker with no argument)
#   wt list                      List worktrees for the current repo
#   wt rm [branch|path]          Remove a worktree (default: current)
#   wt rename <name>             Rename current worktree and its branch
# ------------------------------------------------------------------------------

wt() {
  local __wt_cd_file rc
  __wt_cd_file="$(mktemp)" || {
    # If mktemp fails, still run the command (just without the cd support).
    command wt "$@"
    return $?
  }

  WT_CD_FILE="$__wt_cd_file" command wt "$@"
  rc=$?

  if [[ -s "$__wt_cd_file" ]]; then
    builtin cd -- "$(cat "$__wt_cd_file")"
  fi

  rm -f "$__wt_cd_file"
  return $rc
}

# --- Completion ---------------------------------------------------------------

_wt_completion() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  local -a subcmds
  subcmds=(
    'new:create a new worktree for a branch'
    'create:create a Linear ticket and a worktree for it'
    'info:show the Linear ticket for the current worktree'
    'jump:jump to a worktree'
    'j:alias for jump'
    'list:list worktrees'
    'ls:alias for list'
    'rm:remove a worktree'
    'remove:alias for rm'
    'rename:rename current worktree and branch'
    'help:show help'
  )

  if (( CURRENT == 2 )); then
    _describe -t commands 'wt command' subcmds
    return
  fi

  case "$words[2]" in
    new)
      local -a branches
      branches=("${(@f)$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)}")
      # After `--on`, complete the base ref (existing branch).
      if [[ "$words[CURRENT-1]" == "--on" ]]; then
        _describe -t branches 'base branch' branches
        return
      fi
      _alternative \
        "options:option:((--on:base a new branch on <base>))" \
        "branches:branch name:($branches)" \
        'values:new branch:_default'
      ;;
    jump|j|rm|remove)
      local -a names
      names=("${(@f)$(git worktree list --porcelain 2>/dev/null \
        | awk '/^branch refs\/heads\//{print substr($0,19)}')}")
      _describe -t worktrees 'worktree' names
      ;;
    *)
      ;;
  esac
}

compdef _wt_completion wt
