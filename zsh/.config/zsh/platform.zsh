# platform CLI — manage atai EKS contexts

typeset -A _platform_contexts=(
  dev   "arn:aws:eks:us-west-2:955063685434:cluster/atai-platform-dev-platform"
  stage "arn:aws:eks:us-west-2:434965218828:cluster/atai-platform-stage-platform"
  prod  "arn:aws:eks:us-west-2:012698924477:cluster/atai-platform-prod-platform"
)

_platform_sso_session=atai

platform-auth() {
  aws sso login --sso-session "$_platform_sso_session"
}

platform-is-authed() {
  # Check if SSO session is valid by trying a quick STS call on any profile
  aws sts get-caller-identity --profile atai-prod &>/dev/null
}

platform-switch() {
  local env=$1
  if [[ -z "$env" ]]; then
    echo "Usage: platform switch <dev|stage|prod>"
    return 1
  fi

  local ctx=${_platform_contexts[$env]}
  if [[ -z "$ctx" ]]; then
    echo "Unknown environment: $env (expected dev, stage, or prod)"
    return 1
  fi

  if ! platform-is-authed; then
    echo "SSO session expired, authenticating..."
    platform-auth || return 1
  fi

  kubectl config use-context "$ctx"
}

platform() {
  case $1 in
    auth)   platform-auth ;;
    switch) platform-switch "$2" ;;
    *)
      echo "Usage: platform <auth|switch>"
      echo "  auth              Authenticate to AWS SSO"
      echo "  switch <env>      Switch kubectl context (dev, stage, prod)"
      return 1
      ;;
  esac
}

_platform() {
  local -a subcmds=('auth:Authenticate to AWS SSO' 'switch:Switch kubectl context')
  local -a envs=('dev:Dev environment' 'stage:Stage environment' 'prod:Prod environment')

  _arguments '1:subcommand:->subcmd' '2:environment:->env'

  case $state in
    subcmd) _describe 'subcommand' subcmds ;;
    env)
      [[ $words[2] == "switch" ]] && _describe 'environment' envs
      ;;
  esac
}

compdef _platform platform
