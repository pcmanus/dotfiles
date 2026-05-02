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

  export ARCHETYPEAI_API_KEY="$ATAI_API_KEY"
  export ARCHETYPEAI_API_ENDPOINT="$ATAI_API_ENDPOINT"
}

wprofile-show() {
  echo "WPROFILE=$WPROFILE"
  echo "ATAI_API_KEY=${ATAI_API_KEY:+<set>}"
  echo "ATAI_API_ENDPOINT=$ATAI_API_ENDPOINT"
}

wpcurl() {
  if [[ -z "$ATAI_API_ENDPOINT" || -z "$ATAI_API_KEY" ]]; then
    echo "error: ATAI_API_ENDPOINT and ATAI_API_KEY must be set (use wprofile first)"
    return 1
  fi

  local url_path=""
  local json_input=false
  local verbose=false
  local -a pre_args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -j) json_input=true; shift ;;
      -v) verbose=true; shift ;;
      -X) pre_args+=("$1" "$2"); shift 2 ;;
      -*) pre_args+=("$1"); shift ;;
      *)  url_path="$1"; shift; break ;;
    esac
  done

  if [[ -z "$url_path" ]]; then
    echo "usage: wpcurl [curl-options] [-j] <path> [more-curl-options]"
    return 1
  fi

  local -a json_args=()
  if [[ "$json_input" == true ]]; then
    local tmpfile="${TMPDIR:-/tmp}/wpcurl-body.json"
    ${EDITOR:-vim} "$tmpfile"
    if [[ ! -s "$tmpfile" ]]; then
      echo "aborted: empty file"
      return 1
    fi
    json_args=(-X POST -H "Content-Type: application/json" -d @"$tmpfile")
  fi

  if [[ "$verbose" == true ]]; then
    local -a display_cmd=(curl -H "Authorization: Bearer $ATAI_API_KEY" "${pre_args[@]}")
    if [[ "$json_input" == true ]]; then
      display_cmd+=(-X POST -H "Content-Type: application/json" -d "$(cat "$tmpfile")")
    fi
    display_cmd+=("${ATAI_API_ENDPOINT}${url_path}" "$@")
    print -r -- "${(j: :)${(@q-)display_cmd}} | jq ."
    curl -s -H "Authorization: Bearer $ATAI_API_KEY" "${pre_args[@]}" "${json_args[@]}" "${ATAI_API_ENDPOINT}${url_path}" "$@" | jq .
    return
  fi

  local response http_code
  response=$(curl -s -w '\n%{http_code}' -H "Authorization: Bearer $ATAI_API_KEY" "${pre_args[@]}" "${json_args[@]}" "${ATAI_API_ENDPOINT}${url_path}" "$@")
  [[ -n "$tmpfile" ]] && rm -f "$tmpfile"
  http_code=${response##*$'\n'}
  response=${response%$'\n'*}

  if (( http_code >= 400 )); then
    print -P "%F{red}error: HTTP $http_code%f" >&2
  fi
  if echo "$response" | jq . 2>/dev/null; then
    (( http_code >= 400 ))  && return 1
    return
  fi
  echo "$response"
  (( http_code >= 400 )) && return 1
}

_wprofile_completion() {
  reply=(dev staging prod)
}
compctl -K _wprofile_completion wprofile

wprofile dev
