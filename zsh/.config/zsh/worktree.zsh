# ------------------------------------------------------------------------------
# Git worktree helpers for zsh
#
# Layout:
#   main repo:           ~/src/myrepo
#   linked worktrees:    $HOME/.worktrees/myrepo/<sanitized-branch>
#
# Commands:
#   wt new <branch>        Create a new worktree for branch and cd into it
#   wt jump [name]         Jump to a worktree (fzf picker if no argument)
#   wt list                List worktrees for current repo
#   wt rm [branch|path]    Remove a worktree (default: current)
#   wt rename <name>       Rename current worktree and its branch
#
# Optional:
#   - fzf for wt jump (without argument)
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
_wt_common_dir() {
  local d
  d="$(git rev-parse --git-common-dir 2>/dev/null)" || return 1
  cd "$d" 2>/dev/null && pwd -P
}

# Path of the main worktree for this repository.
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

# Make a branch name safe as a single directory name.
_wt_sanitize_branch() {
  local branch="$1"
  branch="${branch//\//-}"
  branch="${branch// /-}"
  branch="${branch//:/-}"
  branch="${branch//\\/-}"
  printf '%s\n' "$branch"
}

# Extract a short display name from a branch for the prompt.
#   feature/pldev-123-something → pldev-123
#   pldev-123-something         → pldev-123
#   pldev-123                   → pldev-123
#   my-feature                  → my-feature
_wt_short_name() {
  local branch="$1"
  local name="$branch"
  name="${name#feature/}"
  if [[ "$name" =~ ^([a-zA-Z]+-[0-9]+) ]]; then
    printf '%s\n' "${match[1]}"
  else
    _wt_sanitize_branch "$branch"
  fi
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

# Get the branch checked out in a worktree path.
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

# If PWD is inside the given path, cd to main worktree.
_wt_leave_if_inside() {
  local target="$1"
  local real_pwd real_target
  real_pwd="$(pwd -P)"
  real_target="$(cd "$target" 2>/dev/null && pwd -P)" || return 0
  if [[ "$real_pwd" == "$real_target" || "$real_pwd" == "$real_target"/* ]]; then
    local root
    root="$(_wt_main_root)" || return 0
    builtin cd "$root"
  fi
}

# Convert absolute path to tilde-prefixed for starship substitution keys.
_wt_tilde_path() {
  local p="$1"
  if [[ "$p" == "$HOME"/* ]]; then
    printf '%s\n' "~${p#$HOME}"
  else
    printf '%s\n' "$p"
  fi
}

# Add a starship directory substitution for a worktree.
_wt_add_starship_subst() {
  local wpath="$1" display="$2"
  local config="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
  local key
  key="$(_wt_tilde_path "$wpath")"

  [[ -f "$config" ]] || return 0
  grep -qF "\"$key\"" "$config" 2>/dev/null && return 0

  local entry="\"${key}\" = \"${display}\""
  local tmp="${config}.wttmp.$$"
  awk -v entry="$entry" '
    /^\[directory\.substitutions\]/ { print; print entry; next }
    { print }
  ' "$config" > "$tmp" && mv "$tmp" "$config"
}

# Remove a starship directory substitution by worktree path.
_wt_remove_starship_subst() {
  local wpath="$1"
  local config="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
  local key
  key="$(_wt_tilde_path "$wpath")"

  [[ -f "$config" ]] || return 0
  grep -qF "\"$key\"" "$config" 2>/dev/null || return 0

  local tmp="${config}.wttmp.$$"
  grep -vF "\"$key\"" "$config" > "$tmp" && mv "$tmp" "$config"
}

# Check if a worktree is clean. Returns 1 with red error if dirty.
_wt_check_clean() {
  local wpath="$1"
  if [[ -n "$(git -C "$wpath" status --porcelain 2>/dev/null)" ]]; then
    print -P "%F{red}wt: worktree is not clean (has uncommitted or untracked changes)%f" >&2
    return 1
  fi
  return 0
}

# --- Commands -----------------------------------------------------------------

_wt_new() {
  local branch="$1"

  if [[ -z "$branch" ]]; then
    echo "usage: wt new <branch>" >&2
    return 1
  fi

  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  local wpath
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

  local repo short_name
  repo="$(_wt_repo_name)" || return 1
  short_name="$(_wt_short_name "$branch")"
  _wt_add_starship_subst "$wpath" "[${repo}@${short_name}]"

  builtin cd "$wpath" || return 1
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
  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  local wpath

  if [[ -n "$1" ]]; then
    wpath="$(_wt_resolve_worktree_path "$1")" || {
      echo "wt: could not find worktree: $1" >&2
      return 1
    }
    builtin cd "$wpath" || return 1
    return 0
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    echo "wt: fzf not found; available worktrees:" >&2
    _wt_list >&2
    return 1
  fi

  local selection
  selection="$(
    _wt_list_tsv \
      | awk -F '\t' '{
          b = ($2 == "" ? "(detached)" : $2)
          printf "%-8s\t%-35s\t%s\n", $3, b, $1
        }' \
      | fzf --delimiter=$'\t' --with-nth=1,2,3 --prompt='worktree> '
  )" || return 1

  wpath="${selection##*$'\t'}"
  builtin cd "$wpath" || return 1
}

_wt_rm() {
  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  local target="$1"
  local wpath

  if [[ -z "$target" || "$target" == "." ]]; then
    wpath="$(_wt_current_root)" || {
      print -P "%F{red}wt: could not determine current worktree root%f" >&2
      return 1
    }
  else
    wpath="$(_wt_resolve_worktree_path "$target")" || {
      print -P "%F{red}wt: could not resolve worktree: $target%f" >&2
      return 1
    }
  fi

  if _wt_is_main_path "$wpath"; then
    print -P "%F{red}wt: refusing to remove the main worktree%f" >&2
    return 1
  fi

  _wt_check_clean "$wpath" || return 1

  local branch
  branch="$(_wt_branch_for_path "$wpath")"

  git fetch origin 2>/dev/null

  _wt_leave_if_inside "$wpath"

  git worktree remove "$wpath" || {
    print -P "%F{red}wt: failed to remove worktree%f" >&2
    return 1
  }

  _wt_remove_starship_subst "$wpath"

  if [[ -n "$branch" ]]; then
    if _wt_branch_is_merged "$branch"; then
      git branch -D "$branch" 2>/dev/null
    else
      echo "wt: branch '$branch' not merged into origin/main; branch kept"
    fi
  fi
}

# Return 0 if the branch has been merged into origin/main, considering
# both true merges (ancestor check) and squash/rebase merges (via gh).
_wt_branch_is_merged() {
  local branch="$1"

  if git merge-base --is-ancestor "$branch" origin/main 2>/dev/null; then
    return 0
  fi

  if command -v gh >/dev/null 2>&1; then
    local count
    count="$(gh pr list --state merged --head "$branch" --limit 1 --json number --jq 'length' 2>/dev/null)"
    if [[ "$count" == "1" ]]; then
      return 0
    fi
  fi

  return 1
}

_wt_rename() {
  local new_name="$1"

  if [[ -z "$new_name" ]]; then
    echo "usage: wt rename <new-name>" >&2
    return 1
  fi

  if ! _wt_in_repo; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi

  local wpath
  wpath="$(_wt_current_root)" || {
    print -P "%F{red}wt: could not determine current worktree root%f" >&2
    return 1
  }

  if _wt_is_main_path "$wpath"; then
    print -P "%F{red}wt: cannot rename the main worktree%f" >&2
    return 1
  fi

  _wt_check_clean "$wpath" || return 1

  local old_branch
  old_branch="$(_wt_branch_for_path "$wpath")"
  if [[ -z "$old_branch" ]]; then
    print -P "%F{red}wt: worktree has no branch (detached HEAD?)%f" >&2
    return 1
  fi

  if git show-ref --verify --quiet "refs/heads/$new_name"; then
    print -P "%F{red}wt: branch '$new_name' already exists%f" >&2
    return 1
  fi

  local new_path repo short_name
  new_path="$(_wt_branch_path "$new_name")" || return 1
  repo="$(_wt_repo_name)" || return 1
  short_name="$(_wt_short_name "$new_name")"

  if [[ -e "$new_path" ]]; then
    print -P "%F{red}wt: path already exists: $new_path%f" >&2
    return 1
  fi

  # Rename the branch
  git branch -m "$old_branch" "$new_name" || {
    print -P "%F{red}wt: failed to rename branch%f" >&2
    return 1
  }

  # Move the worktree (cd away first since the directory will be moved)
  mkdir -p "$(dirname "$new_path")" || return 1
  local main_root
  main_root="$(_wt_main_root)" || return 1
  builtin cd "$main_root"

  git worktree move "$wpath" "$new_path" || {
    git branch -m "$new_name" "$old_branch" 2>/dev/null
    builtin cd "$wpath" 2>/dev/null
    print -P "%F{red}wt: failed to move worktree%f" >&2
    return 1
  }

  # Update starship substitution
  _wt_remove_starship_subst "$wpath"
  _wt_add_starship_subst "$new_path" "[${repo}@${short_name}]"

  builtin cd "$new_path" || return 1
}

# --- Dispatcher ---------------------------------------------------------------

wt() {
  local cmd="$1"
  shift || true

  case "$cmd" in
    new)       _wt_new "$@" ;;
    jump|j)    _wt_jump "$@" ;;
    list|ls)   _wt_list "$@" ;;
    rm|remove) _wt_rm "$@" ;;
    rename)    _wt_rename "$@" ;;
    ""|help|-h|--help)
      cat <<'EOF'
wt new <branch>        Create a new worktree for branch and cd into it
wt jump [name]         Jump to a worktree (fzf picker if no argument)
wt list                List worktrees for current repo
wt rm [branch|path]    Remove a worktree (default: current)
wt rename <name>       Rename current worktree and its branch
EOF
      ;;
    *)
      echo "wt: unknown command: $cmd" >&2
      return 1
      ;;
  esac
}

# --- Completion ---------------------------------------------------------------

_wt_branches() {
  local -a branches
  branches=("${(@f)$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)}")
  _describe -t branches 'branches' branches
}

_wt_worktree_names() {
  local -a names
  local wpath branch kind
  while IFS=$'\t' read -r wpath branch kind; do
    [[ -n "$branch" ]] && names+=("$branch")
  done < <(_wt_list_tsv 2>/dev/null)
  _describe -t worktrees 'worktree' names
}

_wt_completion() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  local -a subcmds
  subcmds=(
    'new:create a new worktree for a branch'
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
      _alternative \
        'branches:branch name:_wt_branches' \
        'values:new branch:_default'
      ;;
    jump|j|rm|remove)
      _wt_worktree_names
      ;;
    *)
      ;;
  esac
}

compdef _wt_completion wt
