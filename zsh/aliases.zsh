# ---- git ---------------------------------------------------------------------
alias ga='git add'
alias gaa='git add .'
alias gaaa='git add --all'
alias gau='git add --update'
alias gb='git branch'
alias gbd='git branch --delete '
alias gc='git commit'
alias gcf='git commit --fixup'
alias gcm='git commit --message'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcod='git checkout dev'
alias gcom='git checkout master'
alias gd='git diff'
alias gda='git diff HEAD'
alias gg='git status;git add .;git commit;git push'
alias gi='git init'
alias gld='git log --pretty=format:"%h %ad %s" --date=short --all'
alias glg='git log --graph --oneline --decorate --all'
alias gll='git log --graph --pretty=format:'\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%n'\'' --abbrev-commit --date=relative --branches'
alias gm='git merge --no-ff'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gp='git push origin HEAD'
alias gpr='git pull --rebase'
alias gpu='git pull'
alias gr='git rebase'
alias gs='git status'
alias gss='git status --short'
alias gst='git stash'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash push'

# git-contrib (bin/git-contrib): per-author contribution report
# identity map: ~/.config/git-contrib/aliases (machine-local, not in this repo)
alias gitcontrib='git-contrib'
alias gcontrib='git-contrib'
alias gcontrib-fast='git-contrib --no-blame'
alias gcontrib-year='git-contrib --no-blame --since "1 year ago"'
alias gcontrib-deep='git-contrib -d auto'
alias gcontrib-kt='git-contrib -e "kt java" -d auto'

# ---- files -------------------------------------------------------------------
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias md='mkdir -p'
alias rd=rmdir
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
command -v bat >/dev/null || { command -v batcat >/dev/null && alias bat=batcat; }
command -v fd  >/dev/null || { command -v fdfind >/dev/null && alias fd=fdfind; }
alias fzfc='fzf --preview '\''bat --style=numbers --color=always --line-range :500 {}'\'' | xargs -o nvim'

# ---- editor / config ---------------------------------------------------------
alias v='nvim'
alias vc='nvim "$PERSONAL_CONFIG"'
alias zshrc='nvim "$PERSONAL_CONFIG/zsh"'
alias reload='exec zsh'

# ---- android -----------------------------------------------------------------
alias runavd='"$ANDROID_HOME/emulator/emulator" -avd avd'
