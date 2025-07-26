# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ═══════════════════════════════════════════════════════════════════════════════
# TERMINAL CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# History settings
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend

# Terminal behavior
shopt -s checkwinsize
shopt -s autocd
shopt -s cdspell
shopt -s dirspell

# GPG configuration
export GPG_TTY=$(tty)

# Editor
export EDITOR=vim
export VISUAL=vim

# ═══════════════════════════════════════════════════════════════════════════════
# COLORS & THEMING
# ═══════════════════════════════════════════════════════════════════════════════

# Color definitions
declare -A colors=(
    [reset]='\033[0m'
    [bold]='\033[1m'
    [dim]='\033[2m'
    [blue]='\033[38;5;39m'
    [green]='\033[38;5;76m'
    [yellow]='\033[38;5;221m'
    [red]='\033[38;5;196m'
    [purple]='\033[38;5;141m'
    [cyan]='\033[38;5;87m'
    [gray]='\033[38;5;244m'
    [white]='\033[38;5;255m'
)

# ═══════════════════════════════════════════════════════════════════════════════
# GIT INTEGRATION
# ═══════════════════════════════════════════════════════════════════════════════

# Git prompt function
__git_ps1_custom() {
    local branch=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
    if [ -n "$branch" ]; then
        local status=""
        # Check for uncommitted changes
        if ! git diff --quiet 2>/dev/null; then
            status="*"
        fi
        # Check for staged changes
        if ! git diff --cached --quiet 2>/dev/null; then
            status="${status}+"
        fi
        # Check for untracked files
        if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
            status="${status}?"
        fi
        echo -e " ${colors[gray]}⎇${colors[reset]}${colors[yellow]}($branch$status)${colors[reset]}"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# CUSTOM PROMPT
# ═══════════════════════════════════════════════════════════════════════════════

# Main prompt function
__build_prompt() {
    local exit_code=$?
    local prompt=""
    local user="${USER}"
    local host="${HOSTNAME%%.*}"
    local cwd="${PWD##*/}"
    # Top line with user@host and current directory
    prompt="${colors[cyan]}╭─${colors[reset]}"
    prompt+="${colors[gray]}[${colors[reset]}"
    prompt+="${colors[green]}${user}${colors[reset]}"
    prompt+="${colors[gray]}@${colors[reset]}"
    prompt+="${colors[blue]}${host}${colors[reset]}"
    prompt+="${colors[gray]}]${colors[reset]}"
    prompt+="${colors[white]}: ${colors[reset]}"
    prompt+="${colors[purple]}${cwd}${colors[reset]}"
    
    # Git branch info
    prompt+="$(__git_ps1_custom)"
    
    # Error indicator
    if [ $exit_code -ne 0 ]; then
        prompt+=" ${colors[red]}✗${colors[reset]}"
    fi
    
    # New line with input prompt
    prompt+="\n${colors[cyan]}╰─${colors[reset]}${colors[green]}▶${colors[reset]} "
    
    echo -e "$prompt"
}

# Set the prompt
PS1='$(__build_prompt)'

# ═══════════════════════════════════════════════════════════════════════════════
# ALIASES - ESSENTIAL DEVELOPER TOOLS
# ═══════════════════════════════════════════════════════════════════════════════

# Basic commands
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias rmdir='rmdir -v'

# System info
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias jobs='jobs -l'

# Network
alias ping='ping -c 5'
alias ports='netstat -tuln'
alias myip='curl -s ipinfo.io/ip'

# Development specific
alias c='clear'
alias h='history'
alias j='jobs'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcs='git commit -S -m'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gf='git fetch'
alias gpull='git pull'
alias gclone='git clone'

# Quick edit
alias bashrc='$EDITOR ~/.bashrc'
alias vimrc='$EDITOR ~/.vimrc'
alias reload='source ~/.bashrc'

# Directory listing with tree-like structure
alias tree='find . -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"'

# Process management
alias psg='ps aux | grep'
alias kill9='kill -9'
alias killall='killall'

# Archive operations
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Change BG
alias c-bg='feh --bg-fill "$(find ~/Pictures -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n1)"'

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive types
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "Don't know how to extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find files by name
ff() {
    find . -type f -name "*$1*" 2>/dev/null
}

# Find directories by name
fd() {
    find . -type d -name "*$1*" 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# WELCOME MESSAGE
# ═══════════════════════════════════════════════════════════════════════════════

# Display welcome message on login
if [ -n "$PS1" ]; then
    echo -e "\n${colors[cyan]}╭─────────────────────────────────────────────────────────────╮${colors[reset]}"
    echo -e "${colors[cyan]}│${colors[reset]}  ${colors[green]}Welcome back, ${colors[bold]}$USER${colors[reset]}! 🚀                              ${colors[cyan]}    │${colors[reset]}"
    echo -e "${colors[cyan]}│${colors[reset]}                                                           ${colors[cyan]}  │${colors[reset]}"
    echo -e "${colors[cyan]}│${colors[reset]}  ${colors[gray]}System:${colors[reset]} ${colors[white]}$(uname -s)${colors[reset]} ${colors[gray]}•${colors[reset]} ${colors[white]}$(date '+%d %b %Y, %H:%M')${colors[reset]}                ${colors[cyan]}         │${colors[reset]}"
    echo -e "${colors[cyan]}│${colors[reset]}  ${colors[gray]}Shell:${colors[reset]} ${colors[white]}$BASH_VERSION${colors[reset]}                                   ${colors[cyan]}│${colors[reset]}"
    echo -e "${colors[cyan]}│${colors[reset]}                                                             ${colors[cyan]}│${colors[reset]}"
    echo -e "${colors[cyan]}│${colors[reset]}  ${colors[yellow]}Happy coding! 💻${colors[reset]}                                           ${colors[cyan]}│${colors[reset]}"
    echo -e "${colors[cyan]}╰─────────────────────────────────────────────────────────────╯${colors[reset]}\n"
fi
