#!/usr/bin/env bash
# personal-config installer: zsh + Neovim + scripts (+ optional DSA study kit)
# macOS (Homebrew) and Linux (apt / dnf / pacman). Safe to re-run.
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/skydev-x/nvim-config/core/install.sh)"
#   bash -c "$(curl -fsSL .../install.sh)" -- --with-dsa
#
# Options:
#   --with-dsa       also clone the DSA kit (private repo, needs GitHub SSH access) + Kotlin/JDK
#   --no-packages    skip package installs; only clone + link + plugin sync
#   --no-sync        skip the headless Neovim plugin / Mason install
#   --dry-run        print what would happen, change nothing
#   -h, --help
#
# Env overrides: PERSONAL_CONFIG (repo dir), DSA_HOME, REPO_URL, BRANCH, DSA_REPO, KOTLIN_VERSION
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/skydev-x/nvim-config.git}"
BRANCH="${BRANCH:-core}"
PERSONAL_CONFIG="${PERSONAL_CONFIG:-$HOME/personal/personal-config}"
DSA_REPO="${DSA_REPO:-git@github.com:skydev-x/DSA-TERMINAL.git}"
DSA_HOME="${DSA_HOME:-$HOME/personal/docx/swe-prep/dsa}"
KOTLIN_VERSION="${KOTLIN_VERSION:-2.1.21}"
NVIM_MIN="0.11"

WITH_DSA=0 PACKAGES=1 SYNC=1 DRY=0
for a in "$@"; do
  case "$a" in
    --with-dsa) WITH_DSA=1 ;;
    --no-packages) PACKAGES=0 ;;
    --no-sync) SYNC=0 ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,16p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done

B=$'\033[1m' G=$'\033[32m' Y=$'\033[33m' R=$'\033[31m' N=$'\033[0m'
step() { printf '\n%s==> %s%s\n' "$B" "$*" "$N"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '    %s! %s%s\n' "$Y" "$*" "$N"; }
die()  { printf '%sxx %s%s\n' "$R" "$*" "$N" >&2; exit 1; }
run()  { if ((DRY)); then printf '    [dry] %s\n' "$*"; else "$@"; fi; }
has()  { command -v "$1" >/dev/null 2>&1; }

OS="$(uname -s)"; ARCH="$(uname -m)"
TS="$(date +%Y%m%d-%H%M%S)"
SUDO=""; [[ $EUID -ne 0 ]] && has sudo && SUDO="sudo"

# ---------------------------------------------------------------------------
# packages
# ---------------------------------------------------------------------------
install_mac() {
  if ! has brew; then
    step "Installing Homebrew"
    run env NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [[ -x $b ]] && eval "$("$b" shellenv)"; done
  fi
  step "brew packages"
  local pkgs=(git zsh neovim ripgrep fd fzf bat zoxide node python glow make)
  ((WITH_DSA)) && pkgs+=(kotlin openjdk@17)
  run brew install "${pkgs[@]}"
  run brew install --cask font-jetbrains-mono-nerd-font || warn "Nerd Font install failed (agnoster prompt + icons need it)"
}

install_linux() {
  step "system packages"
  if has apt-get; then
    run $SUDO apt-get update -y
    run $SUDO apt-get install -y git zsh curl unzip tar build-essential ripgrep fd-find fzf bat \
      python3 python3-venv nodejs npm
    ((WITH_DSA)) && run $SUDO apt-get install -y openjdk-17-jdk
    run mkdir -p "$HOME/.local/bin"
    if ! has fd && has fdfind; then run ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"; fi
    if ! has bat && has batcat; then run ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"; fi
  elif has dnf; then
    run $SUDO dnf install -y git zsh curl unzip tar gcc make ripgrep fd-find fzf bat python3 nodejs npm zoxide
    ((WITH_DSA)) && run $SUDO dnf install -y java-17-openjdk-devel
  elif has pacman; then
    run $SUDO pacman -Sy --needed --noconfirm git zsh curl unzip tar base-devel ripgrep fd fzf bat \
      python nodejs npm neovim glow zoxide
    ((WITH_DSA)) && run $SUDO pacman -S --needed --noconfirm jdk17-openjdk kotlin
  else
    warn "no apt/dnf/pacman: install git zsh ripgrep fd fzf node python3 make gcc yourself"
  fi
  install_nvim_tarball
  ((WITH_DSA)) && install_kotlinc
  return 0
}

nvim_ok() {
  has nvim || return 1
  local v; v="$(nvim --version | head -1 | sed -E 's/^NVIM v([0-9]+\.[0-9]+).*/\1/')"
  [[ "$(printf '%s\n%s\n' "$NVIM_MIN" "$v" | sort -V | head -1)" == "$NVIM_MIN" ]]
}

# distro neovim is usually too old for vim.lsp.config (needs >= 0.11): use the official tarball
install_nvim_tarball() {
  nvim_ok && { info "neovim $(nvim --version | head -1) ok"; return; }
  step "Neovim (official release tarball -> ~/.local/nvim)"
  local a; case "$ARCH" in x86_64|amd64) a=x86_64 ;; aarch64|arm64) a=arm64 ;; *) die "unsupported arch $ARCH" ;; esac
  local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$a.tar.gz"
  run rm -rf "$HOME/.local/nvim"
  run mkdir -p "$HOME/.local/nvim" "$HOME/.local/bin"
  if ((DRY)); then info "[dry] curl $url | tar -xz"; else curl -fsSL "$url" | tar -xz -C "$HOME/.local/nvim" --strip-components=1; fi
  run ln -sf "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
}

install_kotlinc() {
  has kotlinc && return
  step "kotlinc $KOTLIN_VERSION -> ~/.local/kotlinc"
  local url="https://github.com/JetBrains/kotlin/releases/download/v$KOTLIN_VERSION/kotlin-compiler-$KOTLIN_VERSION.zip"
  local tmp; tmp="$(mktemp -d)"
  if ((DRY)); then info "[dry] curl $url"; return; fi
  curl -fsSL "$url" -o "$tmp/k.zip" && unzip -q "$tmp/k.zip" -d "$tmp"
  rm -rf "$HOME/.local/kotlinc" && mv "$tmp/kotlinc" "$HOME/.local/kotlinc"
  mkdir -p "$HOME/.local/bin" && ln -sf "$HOME/.local/kotlinc/bin/kotlinc" "$HOME/.local/bin/kotlinc"
  rm -rf "$tmp"
}

# ---------------------------------------------------------------------------
# repo, links
# ---------------------------------------------------------------------------
get_repo() {
  step "personal-config repo -> $PERSONAL_CONFIG"
  local here; here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
  if [[ -n "$here" && -f "$here/install.sh" && -d "$here/nvim" && -d "$here/zsh" ]]; then
    PERSONAL_CONFIG="$here"; info "using checkout at $here"
  elif [[ -d "$PERSONAL_CONFIG/.git" ]]; then
    run git -C "$PERSONAL_CONFIG" pull --ff-only || warn "pull failed (local changes?), continuing with what is there"
  else
    run mkdir -p "$(dirname "$PERSONAL_CONFIG")"
    run git clone --branch "$BRANCH" "$REPO_URL" "$PERSONAL_CONFIG"
  fi
}

# link SRC DEST: existing file/dir at DEST is moved to DEST.backup-<time>
link() {
  local src="$1" dest="$2"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then info "ok      $dest"; return; fi
  run mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    run mv "$dest" "$dest.backup-$TS"; info "backup  $dest -> $dest.backup-$TS"
  fi
  run ln -s "$src" "$dest"; info "link    $dest -> $src"
}

link_all() {
  step "Linking"
  local old_zshrc=""
  [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]] && old_zshrc="$HOME/.zshrc.backup-$TS"
  link "$PERSONAL_CONFIG/nvim" "$HOME/.config/nvim"
  link "$PERSONAL_CONFIG/zsh/zshrc" "$HOME/.zshrc"
  link "$PERSONAL_CONFIG/git/ignore" "$HOME/.config/git/ignore"

  if [[ ! -e "$HOME/.zshrc.local" ]]; then
    run cp "$PERSONAL_CONFIG/zsh/zshrc.local.example" "$HOME/.zshrc.local"
    run chmod 600 "$HOME/.zshrc.local"
    info "created ~/.zshrc.local (secrets + machine-only settings go here)"
    if [[ -n "$old_zshrc" ]] && ((!DRY)); then
      local n; n="$(grep -cE '^[[:space:]]*export[[:space:]]+[A-Za-z_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Za-z_]*=' "$old_zshrc" || true)"
      if ((n > 0)); then
        { echo; echo "# moved from old ~/.zshrc by install.sh ($TS)"
          grep -E '^[[:space:]]*export[[:space:]]+[A-Za-z_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Za-z_]*=' "$old_zshrc"; } >> "$HOME/.zshrc.local"
        info "moved $n secret export(s) from old ~/.zshrc into ~/.zshrc.local"
      fi
    fi
  fi
}

zsh_plugins() {
  step "oh-my-zsh + plugins"
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    run env RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    info "oh-my-zsh present"
  fi
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  for p in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
    [[ -d "$custom/${p#*/}" ]] || run git clone --depth 1 "https://github.com/$p" "$custom/${p#*/}"
  done
}

get_dsa() {
  ((WITH_DSA)) || return 0
  step "DSA kit -> $DSA_HOME"
  if [[ -d "$DSA_HOME/.git" ]]; then
    run git -C "$DSA_HOME" pull --ff-only || warn "DSA pull failed, continuing"
  else
    run mkdir -p "$(dirname "$DSA_HOME")"
    run git clone "$DSA_REPO" "$DSA_HOME" || {
      warn "clone failed: $DSA_REPO is private. Add this machine's SSH key to GitHub, then re-run with --with-dsa"
      return 0; }
  fi
  info "study/library/ (converted books) is not in git: copy it from your other machine, or rebuild with"
  info "  tools/vault/build.sh  (needs the source PDFs/HTML)"
}

nvim_sync() {
  ((SYNC)) || return 0
  has nvim || { warn "nvim not found, skipping plugin sync"; return 0; }
  step "Neovim plugins (lazy.nvim restore from lazy-lock.json) + Mason tools"
  run nvim --headless "+Lazy! restore" +qa || warn "Lazy restore reported errors; open nvim and run :Lazy"
  run nvim --headless "+MasonToolsInstallSync" +qa || warn "Mason install reported errors; open nvim and run :Mason"
}

# ---------------------------------------------------------------------------
main() {
  printf '%spersonal-config installer%s  (%s %s%s)\n' "$B" "$N" "$OS" "$ARCH" "$( ((DRY)) && echo ', dry run')"
  if ((PACKAGES)); then
    case "$OS" in
      Darwin) install_mac ;;
      Linux) install_linux ;;
      *) die "unsupported OS: $OS" ;;
    esac
  fi
  has git || die "git is required"
  get_repo
  zsh_plugins
  link_all
  get_dsa
  nvim_sync

  step "Done"
  if [[ "$(basename "${SHELL:-}")" != "zsh" ]]; then
    info "make zsh your login shell:  chsh -s \"$(command -v zsh || echo /bin/zsh)\""
  fi
  info "open a new terminal (or: exec zsh); set the terminal font to a Nerd Font"
  info "secrets: ~/.zshrc.local   ·   update later: dotfiles update"
}

main
