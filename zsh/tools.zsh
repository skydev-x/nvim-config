# Tool integrations: each loads only if the tool is installed.

# fzf key bindings: Ctrl-T files, Ctrl-R history, Alt-C cd
if command -v fzf >/dev/null; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    for f in /usr/share/doc/fzf/examples/key-bindings.zsh /usr/share/fzf/key-bindings.zsh; do
      [[ -r "$f" ]] && source "$f" && break
    done
  fi
  command -v fd >/dev/null && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi

# zoxide: `z foo` jumps to the most used dir matching foo
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY
