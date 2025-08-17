# -----------------------------------------
# Environment
# -----------------------------------------
export ZDOTDIR="${ZDOTDIR:-$HOME}"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less -R"

# PATH (Homebrew first), dedup
path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $path
)
typeset -U path PATH

# -----------------------------------------
# Completion first (needed before plugins)
# -----------------------------------------
autoload -Uz compinit
COMPINIT_FILE="${ZDOTDIR}/.zcompdump"
if [[ -r "$COMPINIT_FILE" ]]; then
  compinit -C -d "$COMPINIT_FILE"
else
  compinit -d "$COMPINIT_FILE"
fi

# -----------------------------------------
# Prompt and core tools (order matters)
# -----------------------------------------
# Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Fast, non-laggy suggestions:
if command -v zsh-autosuggestions >/dev/null 2>&1; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if command -v zsh-syntax-highlighting >/dev/null 2>&1; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# -----------------------------------------
# Aliases (mac-only)
# -----------------------------------------
alias ezrc='nano ~/.zshrc'
alias da='date "+%Y-%m-%d %A %T %Z"'

alias cp='cp -i'
alias mv='mv -i'
if command -v trash >/dev/null 2>&1; then
  alias rm='trash -v'
else
  alias rm='rm -i'
fi
alias mkdir='mkdir -p'
alias less='less -R'
alias cls='clear'
alias vi='nvim'
alias svi='sudo nvim'
alias vis='nvim "+set si"'

# eza for listings
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -aF --group-directories-first --icons --color=auto'
  alias la='eza -alh --group-directories-first --icons'
  alias ll='eza -al --group-directories-first --icons'
  alias lr='eza -alR --group-directories-first --icons'
  alias lt='eza -al --sort=modified --reverse --group-directories-first --icons'
  alias lw='eza -a --oneline --icons'
  alias labc='eza -a --sort=name --icons'
  alias lk='eza -al --sort=size --reverse --icons'
  alias lx='eza -al --sort=ext --icons'
  alias lla='eza -al --icons'
  alias las='eza -a --icons'
  alias lls='eza -l --icons'
else
  alias ls='ls -aFhG'
  alias la='ls -Alh'
  alias ll='ls -Fls'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# chmod helpers
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Disk and mounts
alias folders='du -h'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias mountedinfo='df -h'

# tree
if command -v eza >/dev/null 2>&1; then
  alias tree='eza -T -l --group-directories-first --icons'
  alias treed='eza -T -D --icons'
elif command -v tree >/dev/null 2>&1; then
  alias tree='tree -CAhF --dirsfirst'
  alias treed='tree -CAFd'
fi

# Archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvzf'  # note: bunzip2 or tar -xjf for .bz2
alias ungz='tar -xvzf'

# Logs
alias logs="sudo find /var/log -type f -exec file {} \; | \
  grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | \
  grep -v '[0-9]$' | xargs tail -f"

# Hashing
alias sha1='shasum -a 1'

# Docker
alias dup='docker compose up -d --pull always --force-recreate'
alias docker-clean='docker container prune -f; docker image prune -f; docker network prune -f; docker volume prune -f'

# Kitty
alias kssh="kitty +kitten ssh"

# External scripts
alias jc='bash <(curl -fsSL jaredcervantes.com/mac)'
alias apps='bash <(curl -fsSL https://raw.githubusercontent.com/Jaredy899/mac/main/homebrew_scripts/brew_updater.sh)'
alias os='sh <(curl -fsSL jaredcervantes.com/os)'

# DNS flush (mac)
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'


# Dev shortcut

# pnpm dev shortcut
pd() {
  local dir
  dir="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
  (cd "$dir" && pnpm dev)
}

#rust
cr() {
  local dir
  dir="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
  (cd "$dir" && cargo run)
}

# -----------------------------------------
# ripgrep + bat integrations
# -----------------------------------------
ftext() {
  local q="$1"
  if [[ -z "$q" ]]; then
    echo "Usage: ftext <pattern>"
    return 1
  fi
  if command -v rg >/dev/null 2>&1; then
    if command -v bat >/dev/null 2>&1; then
      rg --hidden --no-ignore-vcs -n --smart-case --color=always "$q" \
        | while IFS=: read -r file line rest; do
            [[ -z "$file" || -z "$line" ]] && continue
            echo "==> $file:$line <=="
            bat --style=plain --color=always --line-range "$line":"$line" "$file"
          done | less -R
    else
      rg --hidden --no-ignore-vcs -n --smart-case --color=always "$q" | less -R
    fi
  else
    grep -iIHrn --color=always "$q" . | less -R
  fi
}

ff() {
  local q="$1"
  [[ -z "$q" ]] && { echo "Usage: ff <pattern>"; return 1; }
  if command -v rg >/dev/null 2>&1; then
    rg --hidden --no-ignore-vcs -n --smart-case -S --color=always "$q" | less -R
  else
    find . -type f -print0 | xargs -0 grep -nI --color=always "$q" | less -R
  fi
}

preview() {
  [[ -z "$1" ]] && { echo "Usage: preview <file>"; return 1; }
  if command -v bat >/dev/null 2>&1; then
    bat --style=plain --paging=always "$1"
  else
    less -R "$1"
  fi
}

if command -v fzf >/dev/null 2>&1; then
  if command -v bat >/dev/null 2>&1; then
    alias nfzf='nano "$(fzf -m --preview=\"bat --color=always {}\")"'
  else
    alias nfzf='nano "$(fzf -m)"'
  fi
fi

# -----------------------------------------
# Git helpers
# -----------------------------------------
gcom() {
  git add .
  git commit -m "$1"
}
lazyg() {
  git add .
  git commit -m "$1"
  git push
}
newb() {
  local branch="$1"; shift
  local msg="$*"
  if [[ -z "$branch" || -z "$msg" ]]; then
    echo "Usage: newb <branch> <commit message>"
    return 1
  fi
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not a git repo"; return 1; }
  git checkout -b "$branch" || return 1
  git add .
  git commit -m "$msg" || return 1
  git push -u origin "$branch"
}

# Fuzzy branch picker (requires fzf)
gs() {
    branch=$(git branch --all --color=never \
        | sed 's/^[* ]*//' \
        | sort -u \
        | fzf --prompt="Switch to branch: ")

    if [ -n "$branch" ]; then
        # Remove "remotes/" prefix if present
        clean_branch="${branch#remotes/}"

        if [[ "$branch" == remotes/* ]]; then
            git switch --track "$clean_branch" 2>/dev/null || \
            git checkout -b "${clean_branch#origin/}" --track "$clean_branch"
        else
            git switch "$clean_branch"
        fi
    fi
}

alias gp='git pull'
alias gb='git branch'
alias gbd='git branch -D'        # usage: gbd <branch>

# -----------------------------------------
# File ops with cd
# -----------------------------------------
cpg() {
  if [[ -d "$2" ]]; then cp "$1" "$2" && cd "$2"; else cp "$1" "$2"; fi
}
mvg() {
  if [[ -d "$2" ]]; then mv "$1" "$2" && cd "$2"; else mv "$1" "$2"; fi
}
mkdirg() {
  [[ -z "$1" ]] && { echo "Usage: mkdirg <directory>"; return 1; }
  mkdir -p "$1" && cd "$1"
}
up() {
  local limit=${1:-1}
  [[ "$limit" =~ ^[0-9]+$ ]] || { echo "Usage: up <number>"; return 1; }
  local d=""
  for ((i = 1; i <= limit; i++)); do d="../$d"; done
  cd "${d%/}"
}
cd() {
  if [[ -n "$1" ]]; then builtin cd "$@" && ls; else builtin cd ~ && ls; fi
}
pwdtail() {
  pwd | awk -F/ '{nlast = NF -1; print $nlast"/"$NF}'
}

# cat -> bat (plain), with fallback
if command -v bat >/dev/null 2>&1; then
  # Keep colors for syntax, no extra decorations; behave like cat
  alias cat='bat --plain --paging=never --color=auto'
fi

# -----------------------------------------
# IP helpers (mac)
# -----------------------------------------
alias whatismyip="whatsmyip"
whatsmyip() {
  echo "Internal IP:"
  ipconfig getifaddr en0 2>/dev/null | sed 's/^/  /'
  ipconfig getifaddr en1 2>/dev/null | sed 's/^/  /'
  echo "External IP:"
  curl -sS https://ifconfig.me || curl -sS https://api.ipify.org
  echo
}

# -----------------------------------------
# Fastfetch (run synchronously in interactive shells)
# -----------------------------------------
if [[ -o interactive ]] && command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi
