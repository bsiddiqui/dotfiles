function cdmkdir() {
  mkdir -p "$1" && cd "$1"
}

function c() {
  local target="${1:-}"

  if [ -z "$target" ]; then
    cd "$HOME/code"
  else
    cd "$HOME/code/$target"
  fi
}

if typeset -f compdef >/dev/null 2>&1; then
  function _c() { _files -W "$HOME/code" -/ }
  compdef _c c
fi

function get_git_branch() {
  git branch --show-current 2>/dev/null
}

function dash() {
  open "dash://$1"
}

function compress_mp4() {
  for file in "$@"; do
    ffmpeg -y -i "$file" -vcodec h264 -preset ultrafast -pix_fmt yuv420p -movflags faststart "${file%.*}-compressed.mp4"
  done
}

function source_env() {
  local env_file="${1:-.env.local}"

  if [ ! -f "$env_file" ]; then
    echo "No env file found at $env_file" >&2
    return 1
  fi

  set -a
  source "$env_file"
  set +a
}
