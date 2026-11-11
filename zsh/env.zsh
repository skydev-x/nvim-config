# Environment variables (no secrets here: use ~/.zshrc.local)

export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"
export LANG="${LANG:-en_US.UTF-8}"

# DSA kit + study vault (install.sh --with-dsa clones it here)
export DSA_HOME="${DSA_HOME:-$HOME/personal/docx/swe-prep/dsa}"

# Go
export GOPATH="${GOPATH:-$HOME/go}"

# Android SDK
if [[ -z "$ANDROID_HOME" ]]; then
  for d in "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
    [[ -d "$d" ]] && export ANDROID_HOME="$d" && break
  done
fi

# Java 17 (Homebrew on macOS, distro package on Linux)
if [[ -z "$JAVA_HOME" ]]; then
  for d in /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home \
           /usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home \
           /usr/lib/jvm/java-17-openjdk*(N) /usr/lib/jvm/java-17*(N); do
    [[ -d "$d" ]] && export JAVA_HOME="$d" && break
  done
fi
