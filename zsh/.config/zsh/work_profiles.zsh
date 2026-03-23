# ---- Work profile support ----

wprofile() {
  local profile="$1"
  local profile_file="$HOME/.config/work-profiles/${profile}.zsh"

  if [[ -z "$profile" ]]; then
    echo "usage: wprofile <dev|staging|prod>"
    return 1
  fi

  if [[ ! -f "$profile_file" ]]; then
    echo "unknown work profile: $profile"
    echo "expected file: $profile_file"
    return 1
  fi

  export WPROFILE="$profile"
  source "$profile_file"
}

wprofile-show() {
  echo "WPROFILE=$WPROFILE"
  echo "ATAI_API_KEY=${ATAI_API_KEY:+<set>}"
  echo "ATAI_API_ENDPOINT=$ATAI_API_ENDPOINT"
}

_wprofile_completion() {
  reply=(dev staging prod)
}
compctl -K _wprofile_completion wprofile

wprofile dev
