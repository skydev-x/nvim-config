# personal-config

Portable setup for macOS and Linux, installed with one command: zsh, Neovim, personal scripts and the DSA study system.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/skydev-x/nvim-config/core/install.sh)"

# also install the DSA kit + Kotlin/JDK (private repo: the machine needs a GitHub SSH key)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/skydev-x/nvim-config/core/install.sh)" _ --with-dsa
```

The script is safe to re-run. Any file it replaces is first moved to `<name>.backup-<time>`.

| Option | Effect |
|---|---|
| `--with-dsa` | clone the DSA kit to `$DSA_HOME` and install `kotlinc` + JDK 17 |
| `--no-packages` | skip brew/apt/dnf/pacman; only clone, link and sync plugins |
| `--no-sync` | skip the headless `Lazy! restore` + Mason install |
| `--dry-run` | print the steps without changing anything |

## What it does

1. **Packages.** macOS uses Homebrew (installed if missing): git, zsh, neovim, ripgrep, fd, fzf, bat, zoxide, node, python, glow, and the JetBrains Mono Nerd Font. Linux uses apt, dnf or pacman. Neovim comes from the official release tarball (`~/.local/nvim`), because distro builds are older than 0.11.
2. **Repo.** Clones this branch to `~/personal/personal-config` (override with `$PERSONAL_CONFIG`).
3. **oh-my-zsh**, plus the `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins.
4. **Links.**

   | Link | Target |
   |---|---|
   | `~/.config/nvim` | `nvim/` |
   | `~/.zshrc` | `zsh/zshrc` |
   | `~/.config/git/ignore` | `git/ignore` |

5. **`~/.zshrc.local`.** Created from `zsh/zshrc.local.example` with mode `600`. Any `export *KEY*`, `*TOKEN*`, `*SECRET*` or `*PASSWORD*` lines from the old `~/.zshrc` are moved into it. **Secrets live only there and are never committed.**
6. **DSA kit** (with `--with-dsa`). Clones `skydev-x/DSA-TERMINAL` to `$DSA_HOME` (default `~/personal/docx/swe-prep/dsa`).
7. **Neovim plugins.** `Lazy! restore` (exact versions from `lazy-lock.json`), then `MasonToolsInstallSync`.

## Layout

```
install.sh              one-command setup
bin/                    on PATH: personal scripts
  dotfiles              update | install | status | edit | cd
  git-contrib           per-author contribution report (blame + churn)
zsh/
  zshrc                 loader: env -> path -> oh-my-zsh -> aliases -> functions -> tools -> ~/.zshrc.local
  env.zsh               EDITOR, DSA_HOME, GOPATH, ANDROID_HOME, JAVA_HOME (macOS + Linux paths)
  path.zsh              brew shellenv, asdf, ~/.local/bin, bin/, Go, Android SDK (existing dirs only, deduped)
  aliases.zsh           git, files, editor, git-contrib
  functions.zsh         dsa, dsacd, runkt, mkcd, claude multi-account
  tools.zsh             fzf keys, zoxide, history
  zshrc.local.example   template for machine-only settings + secrets
nvim/                   Neovim config (lazy.nvim, LSP via Mason, conform, nvim-lint, telescope, …)
  lua/core/study.lua    loads the DSA kit's nvim/dsa.lua when $DSA_HOME exists
git/ignore              global gitignore
```

## Daily use

```bash
dotfiles update        # pull latest + re-link + plugin sync
dotfiles status        # repo state + where each link points
vc                     # open this repo in nvim
dsa plan               # DSA kit from any directory (also: dsa test 21, dsa review, dsacd)
```

Add a script: drop an executable into `bin/`. It is on `PATH` in every new shell.

## Neovim keys changed in this branch

| Key | Now | Was |
|---|---|---|
| `<leader>Lo` `Ll` `Lt` `Ls` | Leet menu, list, test, submit | `<leader>L` `l` `t` `s`, which shadowed `<leader>t*`, `<leader>s*` and `<leader>ll` |
| `<leader>ld` | line diagnostics | `<leader>d`, which delayed every DSA `<leader>d*` key |
| `<leader>rn` | LSP rename with live preview (inc-rename) | two conflicting maps |

DSA study keys (with the kit installed):

| Key | Does |
|---|---|
| `<leader>dt` | run tests |
| `<leader>dh` | hints |
| `<leader>ds` | open the solution |
| `<leader>dd` | diff against the solution |
| `<leader>dn` | next problem |
| `<leader>dp` | this week's plan |
| `<leader>dl` | find a note |
| `<leader>dg` | grep the notes |
| `<leader>db` | backlinks |
| `Enter`, `Tab`, `Backspace` | follow, next and back between links in study notes |

See `$DSA_HOME/study/HOW TO USE.md`.

## Not in git (per machine)

| Path | Holds |
|---|---|
| `~/.zshrc.local` | secrets, machine-only settings |
| `~/.zshenv` | `ZSH_THEME` overrides |
| `~/.config/git-contrib/aliases` | email identity map |
| `~/.gitconfig` | name and email |
| `$DSA_HOME/study/library/` | converted books: copy from another machine or rebuild with `tools/vault/build.sh` |
