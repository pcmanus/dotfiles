# ------------------------------------------------------------------------------
# Git worktree helpers for zsh
#
# Layout:
#   main repo:           ~/src/myrepo
#   linked worktrees:    $HOME/.worktrees/myrepo/<sanitized-branch>
#
# Commands:
#   wt new <branch>        Create/switch to a worktree for branch
#   wt add <branch>        Alias for new
#   wt jump                Fuzzy-jump to one of this repo's worktrees
#   wt list                List worktrees
#   wt rm <branch|path>    Remove a linked worktree
#   wt done <branch|path>  Remove worktree, try deleting local branch, prune
#   wt repo                Cd to the main worktree
#   wt path [branch]       Print worktree path root or branch path
#   wt prune               Prune stale metadata
#
# Optional:
#   - fzf for wt jump
# ------------------------------------------------------------------------------

# Return 0 if inside a git worktree/repo.
_wt_in_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Absolute path to the current worktree root.
_wt_current_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

# Absolute path to the shared git dir for this repository.
# Same across all linked worktrees.
_wt_common_dir() {
  local d
  d="$(git rev-parse --git-common-dir 2>/dev/null)" || return 1
  cd "$d" 2>/dev/null && pwd -P
}

# Absolute path to the current worktree's own .git dir.
_wt_git_dir() {
  local d
  d="$(git rev-parse --absolute-git-dir 2>/dev/null)" || return 1
  cd "$d" 2>/dev/null && pwd -P
}

# Path of the main worktree for this repository.
# This is the parent of the shared git dir.
_wt_main_root() {
  local common
  common="$(_wt_common_dir)" || return 1
  cd "$common/.." 2>/dev/null && pwd -P
}

# Repo display name, based on the main worktree directory name.
_wt_repo_name() {
  local root
  root="$(_wt_main_root)" || return 1
  basename "$root"
}

# Root directory where linked worktrees are stored for this repo.
_wt_repo_wt_root() {
  local repo
  repo="$(_wt_repo_name)" || return 1
  printf '%s\n' "$HOME/.worktrees/$repo"
}

# Symlink path for a repo (used for short prompt display).
_wt_repo_symlink() {
  local repo="$1"
  printf '%s\n' "$HOME/.wt/${repo}"
}

# Create/update the prompt symlink for a repo's worktree.
_wt_update_symlink() {
  local repo="$1" target="$2"
  local sym
  sym="$(_wt_repo_symlink "$repo")"
  mkdir -p "$HOME/.wt"
  ln -sfn "$target" "$sym"
}

# Remove the prompt symlink if it points to the given target.
_wt_remove_symlink() {
  local repo="$1" target="$2"
  local sym
  sym="$(_wt_repo_symlink "$repo")"
  [[ -L "$sym" ]] || return 0
  local cur
  cur="$(readlink "$sym")"
  [[ "$cur" == "$target" ]] && rm -f "$sym"
  # Remove ~/.wt if empty
  rmdir "$HOME/.wt" 2>/dev/null || true
}

# Ensure starship.toml has a directory substitution for this repo.
_wt_ensure_starship_subst() {
  local repo="$1"
  local config="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
  local key="~/.wt/${repo}"

  [[ -f "$config" ]] || return 0
  grep -qF "$key" "$config" 2>/dev/null && return 0

  local entry="\"${key}\" = \"[wt ${repo}]\""
  local tmp="${config}.wttmp.$$"
  awk -v entry="$entry" '
    /^\[directory\.substitutions\]/ { print; print entry; next }
    { print }
  ' "$config" > "$tmp" && mv "$tmp" "$config"
}

# Remove the starship.toml directory substitution for this repo.
_wt_remove_starship_subst() {
  local repo="$1"
  local config="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
  local key="~/.wt/${repo}"

  [[ -f "$config" ]] || return 0
  grep -qF "$key" "$config" 2>/dev/null || return 0

  local tmp="${config}.wttmp.$$"
  grep -vF "$key" "$config" > "$tmp" && mv "$tmp" "$config"
}

# True if the repo has any linked worktrees (besides the main one).
_wt_has_linked_worktrees() {
  local wpath branch kind
  while IFS=$'\t' read -r wpath branch kind; do
    [[ "$kind" == "linked" ]] && return 0
  done < <(_wt_list_tsv)
  return 1
}

# If PWD is inside the given path, cd to main worktree.
_wt_leave_if_inside() {
  local target="$1"
  # Resolve PWD through symlinks for comparison
  local real_pwd real_target
  real_pwd="$(pwd -P)"
  real_target="$(cd "$target" 2>/dev/null && pwd -P)" || return 0
  if [[ "$real_pwd" == "$real_target" || "$real_pwd" == "$real_target"/* ]]; then
    local root
    root="$(_wt_main_root)" || return 0
    builtin cd "$root"
  fi
}

# Make a branch name safe as a single directory name.
# Keeps the real git branch unchanged.
_wt_sanitize_branch() {
  local branch="$1"
  branch="${branch//\//-}"
  branch="${branch// /-}"
  branch="${branch//:/-}"
  branch="${branch//\\/-}"
  printf '%s\n' "$branch"
}

# Path where a branch worktree should live.
_wt_branch_path() {
  local branch="$1"
  local root safe
  root="$(_wt_repo_wt_root)" || return 1
  safe="$(_wt_sanitize_branch "$branch")" || return 1
  printf '%s\n' "$root/$safe"
}

# True if path is the main worktree.
_wt_is_main_path() {
  local wpath="$1"
  local main
  main="$(_wt_main_root)" || return 1
  [[ "$(cd "$wpath" 2>/dev/null && pwd -P)" == "$main" ]]
}

# Emit worktrees as:
#   path<TAB>branch<TAB>kind
# where kind is "main", "linked", or "detached".
_wt_list_tsv() {
  local line wpath branch gitdir kind
  wpath=""
  branch=""
  gitdir=""
  kind="detached"

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" ]]; then
      if [[ -n "$wpath" ]]; then
        if _wt_is_main_path "$wpath"; then
          kind="main"
        elif [[ -n "$branch" ]]; then
          kind="linked"
        else
          kind="detached"
        fi
        printf '%s\t%s\t%s\n' "$wpath" "$branch" "$kind"
      fi
      wpath=""
      branch=""
      gitdir=""
      kind="detached"
      continue
    fi

    case "$line" in
      worktree\ *)
        wpath="${line#worktree }"
        ;;
      branch\ refs/heads/*)
        branch="${line#branch refs/heads/}"
        ;;
      *)
        ;;
    esac
  done < <(git worktree list --porcelain)

  if [[ -n "$wpath" ]]; then
    if _wt_is_main_path "$wpath"; then
      kind="main"
    elif [[ -n "$branch" ]]; then
      kind="linked"
    else
      kind="detached"
    fi
    printf '%s\t%s\t%s\n' "$wpath" "$branch" "$kind"
  fi
}

# Resolve a branch or path into a concrete worktree path.
_wt_resolve_worktree_path() {
  local arg="$1"
  local candidate wpath branch kind

  [[ -n "$arg" ]] || return 1

  if [[ -d "$arg" ]]; then
    cd "$arg" 2>/dev/null && pwd -P
    return 0
  fi

  candidate="$(_wt_branch_path "$arg")" || return 1
  if [[ -d "$candidate" ]]; then
    cd "$candidate" 2>/dev/null && pwd -P
    return 0
  fi

  while IFS=$'\t' read -r wpath branch kind; do
    if [[ "$branch" == "$arg" ]]; then
      printf '%s\n' "$wpath"
      return 0
    fi
  done < <(_wt_list_tsv)

  return 1
}

# Get the branch currently checked out in a worktree path, if any.
_wt_branch_for_path() {
  local wanted="$1"
  local wpath branch kind

  while IFS=$'\t' read -r wpath branch kind; do
    if [[ "$wpath" == "$wanted" ]]; then
      [[ -n "$branch" ]] && printf '%s\n' "$branch"
      return 0
    fi
  done < <(_wt_list_tsv)

  return 1
}

_wt_new() {
  local branch="$1"
  local wpath

  if [[ -z "$branch" ]]; then
    echo "usage: wt new <branch>" >&2
    return 1
  fi

  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  wpath="$(_wt_branch_path "$branch")" || return 1

  if [[ -e "$wpath" ]]; then
    echo "wt: path already exists: $wpath" >&2
    return 1
  fi

  mkdir -p "$(dirname "$wpath")" || return 1

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$wpath" "$branch" || return 1
  else
    git worktree add -b "$branch" "$wpath" || return 1
  fi

  # Set up symlink and starship substitution for short prompt
  local repo
  repo="$(_wt_repo_name)" || return 1
  _wt_update_symlink "$repo" "$wpath"
  _wt_ensure_starship_subst "$repo"

  # cd through symlink so $PWD uses the short path;
  # use builtin cd + NO_CHASE_LINKS to prevent zoxide / CHASE_LINKS
  # from resolving the symlink back to the real path.
  local sym
  sym="$(_wt_repo_symlink "$repo")"
  setopt local_options NO_CHASE_LINKS
  builtin cd "$sym" || builtin cd "$wpath" || return 1
}

_wt_list() {
  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  printf '%-8s %-35s %s\n' "KIND" "BRANCH" "PATH"
  printf '%-8s %-35s %s\n' "--------" "-----------------------------------" "----"

  _wt_list_tsv | while IFS=$'\t' read -r wpath branch kind; do
    [[ -n "$branch" ]] || branch="(detached)"
    printf '%-8s %-35s %s\n' "$kind" "$branch" "$wpath"
  done
}

_wt_jump() {
  local selection wpath

  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  if command -v fzf >/dev/null 2>&1; then
    selection="$(
      _wt_list_tsv \
        | awk -F '\t' '{
            b = ($2 == "" ? "(detached)" : $2)
            printf "%-8s\t%-35s\t%s\n", $3, b, $1
          }' \
        | fzf --delimiter=$'\t' --with-nth=1,2,3 --prompt='worktree> '
    )" || return 1

    wpath="${selection##*$'\t'}"
    setopt local_options NO_CHASE_LINKS
    # For linked worktrees, cd through symlink for short prompt
    if ! _wt_is_main_path "$wpath"; then
      local repo
      repo="$(_wt_repo_name)" || { builtin cd "$wpath" || return 1; return 0; }
      _wt_update_symlink "$repo" "$wpath"
      _wt_ensure_starship_subst "$repo"
      local sym
      sym="$(_wt_repo_symlink "$repo")"
      builtin cd "$sym" || builtin cd "$wpath" || return 1
    else
      builtin cd "$wpath" || return 1
    fi
  else
    echo "wt: fzf not found; available worktrees:" >&2
    _wt_list >&2
    return 1
  fi
}

_wt_repo() {
  local root
  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi
  root="$(_wt_main_root)" || return 1
  cd "$root" || return 1
}

_wt_path() {
  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  if [[ -n "$1" ]]; then
    _wt_branch_path "$1"
  else
    _wt_repo_wt_root
  fi
}

_wt_rm() {
  local target="$1"
  local wpath

  if [[ -z "$target" ]]; then
    echo "usage: wt rm <branch|path|.>" >&2
    return 1
  fi

  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  # "." means the current worktree
  if [[ "$target" == "." ]]; then
    wpath="$(_wt_current_root)" || {
      echo "wt: could not determine current worktree root" >&2
      return 1
    }
  else
    wpath="$(_wt_resolve_worktree_path "$target")" || {
      echo "wt: could not resolve worktree: $target" >&2
      return 1
    }
  fi

  if _wt_is_main_path "$wpath"; then
    echo "wt: refusing to remove main worktree: $wpath" >&2
    return 1
  fi

  local repo
  repo="$(_wt_repo_name)" || true

  # cd back to main repo if we are inside the worktree being removed
  _wt_leave_if_inside "$wpath"

  git worktree remove "$wpath" || return 1

  if [[ -n "$repo" ]]; then
    _wt_remove_symlink "$repo" "$wpath"
    _wt_has_linked_worktrees || _wt_remove_starship_subst "$repo"
  fi
}

_wt_done() {
  local target="$1"
  local wpath branch

  if [[ -z "$target" ]]; then
    echo "usage: wt done <branch|path|.>" >&2
    return 1
  fi

  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  # "." means the current worktree
  if [[ "$target" == "." ]]; then
    wpath="$(_wt_current_root)" || {
      echo "wt: could not determine current worktree root" >&2
      return 1
    }
  else
    wpath="$(_wt_resolve_worktree_path "$target")" || {
      echo "wt: could not resolve worktree: $target" >&2
      return 1
    }
  fi

  if _wt_is_main_path "$wpath"; then
    echo "wt: refusing to remove main worktree: $wpath" >&2
    return 1
  fi

  branch="$(_wt_branch_for_path "$wpath")"

  local repo
  repo="$(_wt_repo_name)" || true

  # cd back to main repo if we are inside the worktree being removed
  _wt_leave_if_inside "$wpath"

  git worktree remove "$wpath" || return 1

  if [[ -n "$repo" ]]; then
    _wt_remove_symlink "$repo" "$wpath"
    _wt_has_linked_worktrees || _wt_remove_starship_subst "$repo"
  fi

  if [[ -n "$branch" ]]; then
    git branch -d "$branch" >/dev/null 2>&1 || true
  fi

  git worktree prune
}

_wt_prune() {
  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi
  git worktree prune
}

wt() {
  local cmd="$1"
  shift || true

  case "$cmd" in
    new|add)
      _wt_new "$@"
      ;;
    jump|j)
      _wt_jump "$@"
      ;;
    list|ls)
      _wt_list "$@"
      ;;
    rm|remove)
      _wt_rm "$@"
      ;;
    done)
      _wt_done "$@"
      ;;
    repo)
      _wt_repo "$@"
      ;;
    path)
      _wt_path "$@"
      ;;
    prune)
      _wt_prune "$@"
      ;;
    ""|help|-h|--help)
      cat <<'EOF'
wt new <branch>        Create a new worktree for branch and cd into it
wt add <branch>        Same as new
wt jump                Fuzzy-jump to a worktree
wt list                List worktrees for current repo
wt rm <branch|path>    Remove a worktree
wt done <branch|path>  Remove worktree, try deleting local branch, prune
wt repo                Cd to the main worktree
wt path [branch]       Print worktree directory path
wt prune               Prune stale worktree metadata
EOF
      ;;
    *)
      echo "wt: unknown command: $cmd" >&2
      return 1
      ;;
  esac
}

# ------------------------------------------------------------------------------
# zsh completion
# ------------------------------------------------------------------------------

_wt_branches() {
  local -a branches
  branches=("${(@f)$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)}")
  _describe -t branches 'branches' branches
}

_wt_worktrees() {
  local -a items
  local wpath branch kind label

  items=()
  while IFS=$'\t' read -r wpath branch kind; do
    if [[ -n "$branch" ]]; then
      label="$branch [$kind]"
      items+=("$branch:$label")
      items+=("$wpath:$label")
    else
      label="$wpath [$kind]"
      items+=("$wpath:$label")
    fi
  done < <(_wt_list_tsv 2>/dev/null)

  _describe -t worktrees 'worktrees' items
}

_wt_completion() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  local -a subcmds
  subcmds=(
    'new:create a new worktree for a branch'
    'add:same as new'
    'jump:fuzzy-jump to a worktree'
    'j:alias for jump'
    'list:list worktrees'
    'ls:alias for list'
    'rm:remove a linked worktree'
    'remove:alias for rm'
    'done:remove a worktree and try deleting its branch'
    'repo:cd to main worktree'
    'path:print worktree path'
    'prune:prune stale worktree metadata'
    'help:show help'
  )

  if (( CURRENT == 2 )); then
    _describe -t commands 'wt command' subcmds
    return
  fi

  case "$words[2]" in
    new|add)
      _alternative \
        'branches:branch name:_wt_branches' \
        'values:new branch:_default'
      ;;
    rm|remove|done)
      _wt_worktrees
      ;;
    path)
      _alternative \
        'branches:branch name:_wt_branches' \
        'values:branch:_default'
      ;;
    jump|j|list|ls|repo|prune|help)
      ;;
    *)
      ;;
  esac
}

compdef _wt_completion wt
