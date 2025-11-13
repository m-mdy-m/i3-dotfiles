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
    [blue]='\033[38;5;111m'
    [green]='\033[38;5;108m'
    [yellow]='\033[38;5;180m'
    [red]='\033[38;5;204m'
    [purple]='\033[38;5;183m'
    [cyan]='\033[38;5;109m'
    [gray]='\033[38;5;246m'
    [white]='\033[38;5;255m'
)

# ═══════════════════════════════════════════════════════════════════════════════
# GIT INTEGRATION
# ═══════════════════════════════════════════════════════════════════════════════

# Git prompt function
__git_info() {
    # if not a git repo -> nothing
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    # branch / detached detection
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
    local detached=0
    if [[ "$branch" == "HEAD" ]]; then
        branch="detached"
        detached=1
    fi

    # quick flags for repo state (fast checks)
    local staged=0 unstaged=0 untracked=0 conflicted=0
    # staged?
    if ! git diff --cached --quiet --ignore-submodules -- 2>/dev/null; then
        staged=1
    fi
    # unstaged?
    if ! git diff --quiet --ignore-submodules -- 2>/dev/null; then
        unstaged=1
    fi
    # untracked?
    if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
        untracked=1
    fi
    # conflict?
    if [ -n "$(git ls-files -u 2>/dev/null)" ]; then
        conflicted=1
    fi

    # ahead/behind (only if upstream exists)
    local ahead=0 behind=0 remote_status=""
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        local counts
        counts=$(git rev-list --left-right --count @{u}...HEAD 2>/dev/null) || counts=""
        if [[ -n "$counts" ]]; then
            behind=$(echo "$counts" | awk '{print $1}')
            ahead=$(echo "$counts" | awk '{print $2}')
            [[ $ahead -gt 0 ]] && remote_status="↑${ahead}"
            [[ $behind -gt 0 ]] && remote_status="${remote_status}${remote_status:+ }↓${behind}"
        fi
    fi

    # pick color for branch name (do not change palette keys)
    local branch_color="${colors[green]}"
    if [[ $conflicted -eq 1 ]]; then
        branch_color="${colors[red]}"
    elif [[ $staged -eq 1 || $unstaged -eq 1 || $untracked -eq 1 ]]; then
        branch_color="${colors[yellow]}"
    elif [[ $detached -eq 1 ]]; then
        branch_color="${colors[purple]}"
    fi

    # build compact status string (order: staged, unstaged, untracked, conflicted)
    local state=""
    [[ $staged -eq 1 ]] && state="${state}+"
    [[ $unstaged -eq 1 ]] && state="${state}*"
    [[ $untracked -eq 1 ]] && state="${state}?"
    [[ $conflicted -eq 1 ]] && state="${state}!"

    # assemble final piece
    if [[ $detached -eq 1 ]]; then
        # show short commit-ish for detached (optional: show short SHA)
        local shortsha
        shortsha=$(git rev-parse --short HEAD 2>/dev/null || echo "")
        echo -e " ${colors[gray]}⎇${colors[reset]}${branch_color}(${branch}${shortsha:+:${shortsha}}${state:+" ${state}"}${remote_status:+" ${remote_status}"})${colors[reset]}"
    else
        echo -e " ${colors[gray]}⎇${colors[reset]}${branch_color}(${branch}${state:+ ${state}}${remote_status:+ ${remote_status}})${colors[reset]}"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# CUSTOM PROMPT
# ═══════════════════════════════════════════════════════════════════════════════

# Main prompt function
__prompt() {
    local exit=$?
    local cwd="${PWD##*/}"
    [[ "$cwd" == "$USER" ]] && cwd="~"
    
    # Status indicator
    local status="${colors[green]}▶${colors[rest]}"
    [[ $exit -ne 0 ]] && status="${colors[red]}▶${colors[rest]}"
    
    echo -e "${colors[blue]}${cwd}${colors[rest]}$(__git_info) ${status} "
}
# Set the prompt
PS1='$(__prompt)'

# ═══════════════════════════════════════════════════════════════════════════════
# ALIASES - ESSENTIAL DEVELOPER TOOLS
# ═══════════════════════════════════════════════════════════════════════════════

# Basic commands
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -lht'

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
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gf='git fetch'
alias gpull='git pull'
alias gclone='git clone'
alias gl='git log --oneline --graph --decorate --all -20'
alias gd='git diff'
alias gdc='git diff --cached'

# Quick edit
alias bashrc='$EDITOR ~/.bashrc'
alias vimrc='$EDITOR ~/.vimrc'
alias reload='source ~/.bashrc'

# Directory listing with tree-like structure
function tree() {
    local depth=3
    local show_files=true
    local show_dirs=true
    local show_hidden=false
    local show_git=false
    local path="."
    local show_size=false
    local show_permissions=false
    
    # Parse arguments
    while (( $# > 0 )); do
        case $1 in
            -L)
                depth="$2"
                shift 2
                ;;
            -f)
                show_dirs=false
                shift
                ;;
            -d)
                show_files=false
                shift
                ;;
            -a)
                show_hidden=true
                shift
                ;;
            -g)
                show_git=true
                shift
                ;;
            -s)
                show_size=true
                shift
                ;;
            -p)
                show_permissions=true
                shift
                ;;
            -h|--help)
                printf "Usage: tree [OPTIONS] [PATH]\n"
                printf "Options:\n"
                printf "  -L N        Limit depth to N levels (default: 3)\n"
                printf "  -f          Show only files\n"
                printf "  -d          Show only directories\n"
                printf "  -a          Show hidden files/directories\n"
                printf "  -g          Include .git and other VCS directories\n"
                printf "  -s          Show file sizes\n"
                printf "  -p          Show permissions\n"
                printf "  -h, --help  Show this help\n"
                return 0
                ;;
            -*)
                printf "Unknown option: %s\n" "$1"
                return 1
                ;;
            *)
                path="$1"
                shift
                ;;
        esac
    done
    
    # Check if path exists
    if [[ ! -d "$path" && ! -f "$path" ]]; then
        printf "Path not found: %s\n" "$path"
        return 1
    fi
    
    # Internal recursive function to build tree
    _tree_recursive() {
        local current_path="$1"
        local current_depth="$2"
        local prefix="$3"
        local is_last="$4"
        
        # Check depth limit
        if (( current_depth > depth )); then
            return
        fi
        
        # Get items in directory
        local items=()
        local item
        
        # Use different approaches based on what we want to show
        if [[ "$show_hidden" == true ]]; then
            while IFS= read -r -d '' item; do
                items+=("$item")
            done < <(find "$current_path" -maxdepth 1 -mindepth 1 -print0 2>/dev/null | sort -z)
        else
            while IFS= read -r -d '' item; do
                local basename="${item##*/}"
                if [[ "$basename" != .* ]]; then
                    items+=("$item")
                fi
            done < <(find "$current_path" -maxdepth 1 -mindepth 1 -print0 2>/dev/null | sort -z)
        fi
        
        # Filter out VCS directories unless explicitly requested
        if [[ "$show_git" == false ]]; then
            local filtered_items=()
            for item in "${items[@]}"; do
                local basename="${item##*/}"
                if [[ "$basename" != ".git" && "$basename" != ".svn" && "$basename" != ".hg" && "$basename" != ".bzr" ]]; then
                    filtered_items+=("$item")
                fi
            done
            items=("${filtered_items[@]}")
        fi
        
        # Filter by file type
        local final_items=()
        for item in "${items[@]}"; do
            if [[ -d "$item" ]]; then
                if [[ "$show_dirs" == true ]]; then
                    final_items+=("$item")
                fi
            else
                if [[ "$show_files" == true ]]; then
                    final_items+=("$item")
                fi
            fi
        done
        
        # Process each item
        local item_count=${#final_items[@]}
        local i=0
        
        for item in "${final_items[@]}"; do
            i=$((i + 1))
            local is_last_item=false
            if (( i == item_count )); then
                is_last_item=true
            fi
            
            local basename="${item##*/}"
            local tree_char="├── "
            local new_prefix="$prefix│   "
            
            if [[ "$is_last_item" == true ]]; then
                tree_char="└── "
                new_prefix="$prefix    "
            fi
            
            # Determine file type and styling
            local color=""
            local icon=""
            if [[ -d "$item" ]]; then
                color="${colors[blue]}"
                icon="📁"
            elif [[ -x "$item" ]]; then
                color="${colors[green]}"
                icon="⚡"
            else
                case "$basename" in
                    *.txt|*.md|*.rst) color="${colors[white]}"; icon="📄" ;;
                    *.sh|*.bash|*.zsh) color="${colors[green]}"; icon="🔧" ;;
                    *.py) color="${colors[yellow]}"; icon="🐍" ;;
                    *.js|*.ts|*.jsx|*.tsx) color="${colors[yellow]}"; icon="⚡" ;;
                    *.html|*.css|*.scss) color="${colors[purple]}"; icon="🌐" ;;
                    *.json|*.xml|*.yaml|*.yml) color="${colors[cyan]}"; icon="📋" ;;
                    *.jpg|*.jpeg|*.png|*.gif|*.svg) color="${colors[red]}"; icon="🖼️" ;;
                    *.mp3|*.mp4|*.avi|*.mov) color="${colors[red]}"; icon="🎵" ;;
                    *.zip|*.tar|*.gz|*.bz2) color="${colors[gray]}"; icon="📦" ;;
                    *.pdf) color="${colors[red]}"; icon="📕" ;;
                    *.log) color="${colors[gray]}"; icon="📜" ;;
                    *) color="${colors[white]}"; icon="📄" ;;
                esac
            fi
            
            # Build output line
            local output="${colors[gray]}${prefix}${tree_char}${colors[reset]}${icon} ${color}${basename}${colors[reset]}"
            
            # Add size if requested
            if [[ "$show_size" == true && -f "$item" ]]; then
                local size
                if command -v du >/dev/null 2>&1; then
                    size=$(du -h "$item" 2>/dev/null | cut -f1)
                    output+=" ${colors[gray]}(${size})${colors[reset]}"
                fi
            fi
            
            # Add permissions if requested
            if [[ "$show_permissions" == true ]]; then
                local perms
                perms=$(ls -ld "$item" 2>/dev/null | cut -d' ' -f1)
                output+=" ${colors[dim]}${perms}${colors[reset]}"
            fi
            
            printf "%b\n" "$output"
            
            # Recurse into directories
            if [[ -d "$item" && $current_depth -lt $depth ]]; then
                _tree_recursive "$item" $((current_depth + 1)) "$new_prefix" "$is_last_item"
            fi
        done
    }
    
    # Start the tree
    if [[ "$path" != "." ]]; then
        local basename="${path##*/}"
        printf "%s📁 %s%s%s\n" "${colors[blue]}" "${colors[blue]}" "$basename" "${colors[reset]}"
    fi
    
    _tree_recursive "$path" 1 "" false
}

# Quick tree aliases - using single letters to avoid conflicts
alias t1='tree -L 1'          # Depth 1
alias t2='tree -L 2'          # Depth 2  
alias t3='tree -L 3'          # Depth 3
alias t4='tree -L 4'          # Depth 4
alias t5='tree -L 5'          # Depth 5

alias td='tree -d'            # Directories only
alias tf='tree -f'            # Files only
alias ta='tree -a'            # Include hidden files
alias tg='tree -g'            # Include .git directories
alias ts='tree -s'            # Show file sizes
alias tp='tree -p'            # Show permissions

# Combined aliases
alias tds='tree -d -s'        # Directories with sizes
alias tfs='tree -f -s'        # Files with sizes
alias tas='tree -a -s'        # All with sizes
alias tgas='tree -g -a -s'    # Everything with sizes

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

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find file by name
f() {
    find . -iname "*$1*" 2>/dev/null
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

cd() {
    builtin cd "$@" && l
}

cbg() {
    feh --bg-fill "$(find ~/Pictures -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n1)"
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

# Added by Agas installer
export PATH="$PATH:/home/m-mdy-m/.local/bin"
export PATH="$HOME/.bun/bin:$PATH"
