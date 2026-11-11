# PATH: each entry is added only if the directory exists; duplicates are dropped.
typeset -U path PATH

# Homebrew (Apple Silicon, Intel macOS, Linuxbrew): sets PATH, MANPATH, HOMEBREW_*
for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x "$b" ]] && eval "$("$b" shellenv)" && break
done

prepend() { for d in "$@"; do [[ -d "$d" ]] && path=("$d" $path); done; }
append()  { for d in "$@"; do [[ -d "$d" ]] && path+=("$d"); done; }

# asdf
prepend "${ASDF_DATA_DIR:-$HOME/.asdf}/bin" "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"

# personal scripts first, then user-local binaries
prepend "$HOME/.local/bin" "$PERSONAL_CONFIG/bin"

# languages / SDKs
append /usr/local/go/bin "$GOPATH/bin" "$HOME/.cargo/bin"
[[ -n "$JAVA_HOME" ]] && append "$JAVA_HOME/bin"
if [[ -n "$ANDROID_HOME" ]]; then
  append "$ANDROID_HOME/emulator" "$ANDROID_HOME/platform-tools" \
         "$ANDROID_HOME/cmdline-tools/latest/bin" "$ANDROID_HOME/tools" "$ANDROID_HOME/tools/bin"
fi

# Linux installs made by install.sh (nvim tarball, kotlinc)
append "$HOME/.local/nvim/bin" "$HOME/.local/kotlinc/bin"

unfunction prepend append
