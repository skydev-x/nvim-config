# Compile + run a single Kotlin file:  runkt Main.kt
runkt() {
  local name="${1:t:r}"
  kotlinc "$1" -include-runtime -d "$name.jar" && java -jar "$name.jar" "${@:2}"
}

# DSA kit from any directory:  dsa test 21,  dsa plan,  dsa review
dsa() {
  if [[ ! -x "$DSA_HOME/dsa" ]]; then
    echo "DSA kit not found at \$DSA_HOME=$DSA_HOME (install.sh --with-dsa)" >&2
    return 1
  fi
  (cd "$DSA_HOME" && ./dsa "$@")
}
# jump to the kit
dsacd() { cd "$DSA_HOME"; }

# mkdir + cd
mkcd() { mkdir -p "$1" && cd "$1"; }

# >>> claude multi-account >>>
# WORK is the default: plain `claude` uses ~/.claude
# PERSONAL: `claude-personal`, or any `claude` run inside ~/personal, uses ~/.claude-personal
if [[ -d "$HOME/.claude-personal" ]]; then
  claude-personal() { CLAUDE_CONFIG_DIR="$HOME/.claude-personal" command claude "$@"; }
  claude() {
    case "$PWD/" in
      "$HOME/personal/"*) CLAUDE_CONFIG_DIR="$HOME/.claude-personal" command claude "$@" ;;
      *) command claude "$@" ;;
    esac
  }
fi
# <<< claude multi-account <<<
