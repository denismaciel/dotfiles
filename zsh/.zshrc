# zmodload zsh/zprof
source ~/zsh-defer/zsh-defer.plugin.zsh

export PATH=$HOME/dotfiles/scripts:$PATH
export PATH=$PATH:/usr/local/go/bin
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin/:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/node/bin:$PATH"
export PATH="$HOME/venvs/default/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$PATH:/home/denis/.local/bin"
export GOPATH=$(go env GOPATH)
export PATH=$GOROOT/bin:$PATH

export R_LIBS_USER="$HOME/r/x86_64-pc-linux-gnu-library/4.1" # Custom location for R packages
export LC_ALL=en_US.UTF-8 # Fix problem when opening nvim
export VISUAL=nvim
export EDITOR=nvim
export PYTHONBREAKPOINT=ipdb.set_trace
# Fix annoying warning: 
#     - https://nixos.wiki/wiki/Locales
#     - https://www.reddit.com/r/NixOS/comments/oj4kmd/every_time_i_run_a_program_installed_with_nix_i/
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
export DISABLE_AUTO_TITLE='true' # For tmuxp, no idea what it does
export XDG_CONFIG_HOME=$HOME/.config

export COLORSCHEME=dark
export ZK_NOTEBOOK_DIR="$HOME/Sync/Notes/Current"

[[ "$(uname)" = "Linux" ]] && xset r rate 200 40 && setxkbmap -layout us -option ctrl:nocaps

export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
source /home/denis/.nix-profile/etc/profile.d/nix.sh

# ---------------------------
# --------- fzf -------------
# ---------------------------
export FZF_DEFAULT_OPTS="--height 100%"
export FZF_DEFAULT_COMmAND="rg --files --no-ignore-vcs --ignore-file ~/.ripgrep_ignore"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
function _fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" --exclude "venv" . "$1"
}
function  _fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" --exclude "venv" . "$1"
}


# ---------------------------
# --------- aliases ---------
# ---------------------------
alias core='tmuxp load core -y'
alias mine='tmuxp load mine -y'
alias act='source venv/bin/activate'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -lh'
alias lsa='ls -lah' 
alias ls='ls -G --color=auto'
alias R='R --no-save'
alias diary='nvim "$HOME/Sync/Notes/Current/Diary/$(date +'%Y-%m-%d').md"'
alias gp="git push origin HEAD"
alias rm=gomi
alias vi=nvim
alias gdd="GIT_EXTERNAL_DIFF='difft --syntax-highlight off' git diff"
alias gdds="GIT_EXTERNAL_DIFF='difft --syntax-highlight off' git diff --staged"
alias gds="git diff --staged"
alias clip='xclip -selection clipboard'
alias tss="date +'%Y-%m-%d %H:%M:%S' | tr -d '\n' | xclip -selection clipboard && xclip -selection clipboard -o"
alias tsd="date +'%Y-%m-%d' | tr -d '\n' | xclip -selection clipboard && xclip -selection clipboard -o"
alias tsw="date +'%Y-%W' | tr -d '\n' | xclip -selection clipboard && xclip -selection clipboard -o"

setopt autocd # .. is shortcut for cd .. 

# vi mode
bindkey -v
export KEYTIMEOUT=1
bindkey -v '^?' backward-delete-char
bindkey "^E" backward-word
bindkey "^F" forward-word
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search
autoload -U edit-command-line # Enable Ctrl-x-e to edit command line
# Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_SAVE_NO_DUPS         # Dont write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Dont execute immediately upon history expansion.
setopt INTERACTIVE_COMMENTS       # Allow for comments

if [ -e /home/denis/credentials/recap.sh ]; then . /home/denis/credentials/recap.sh; fi


eval "$(starship init zsh)"
eval "$(scmpuff init -s)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"

# ==================
# === zimfw setup ==
# ==================
# zim (https://github.com/zimfw/zimfw
zstyle ':zim:zmodule' use 'degit'
ZIM_HOME=~/.config/zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
    source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
zsh-defer source ${ZIM_HOME}/init.zsh

if [ -n "${commands[fzf-share]}" ]; then
    source "$(fzf-share)/key-bindings.zsh"
    source "$(fzf-share)/completion.zsh"
fi

# ==================
# === Functions ====
# ==================
function mv_last {
    local source_folder="$1"
    local destination_folder="$2"

    # Find the last downloaded file
    last_downloaded_file=$(ls -t1 "$source_folder" | head -n 1)

    # Check if a file was found
    if [ -n "$last_downloaded_file" ]; then
        # Move the file to the destination folder
        mv "$source_folder/$last_downloaded_file" "$destination_folder/$last_downloaded_file"
        echo "Moved the last downloaded file ($last_downloaded_file) to the destination folder."
    else
        echo "No files found in the source folder."
    fi
}

function gbl {
    is_in_git_repo || return
    git branch -a --color=always | grep -v '/HEAD\s' | sort |
        fzf-down --ansi --multi --tac --preview-window right:70% \
        --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
        sed 's/^..//' | cut -d' ' -f1 |
        sed 's#^remotes/origin/##'
}

function gb {
    git checkout $(echo $(gbl) | sed 's#^remotes/##')
}

function togglep() {
    if [[ -f playground/p.go ]]; then 
        echo "==> gopher"
        mv playground/p.go playground/p.gopher
    elif [[ -f playground/p.gopher ]]; then
        echo "==> go"
        mv playground/p.gopher playground/p.go
    else
        echo "No gopher, no go"
        return 1
    fi
}

function open() {
    nohup xdg-open "$*" >> /dev/null &
}

function addin() {
    printf "Addressed in $(git rev-parse HEAD)" | xclip -selection clipboard 
    git push origin HEAD
}

function rename-tmux-window() {
    local current_dir="$(basename "$(pwd)")"
    tmux rename-window "$current_dir"
}

function list-branches() {
    git branch | grep -vE "^\*|main"
}

function pdread() {
    ipython -i -c 'import types, pandas as pd; df = pd.read_csv("'$(realpath $1)'"); c = types.SimpleNamespace(); [setattr(c, col.replace(" ", "").replace(")", "").replace("(", ""), col) for col in df.columns]; print(df)'
}

function add-anki() {
    apy add -d default
}

function zip-folder() {
    if [ $# -eq 0 ]; then
        echo "Usage: zip-folder foldername"
        return 1
    fi
    foldername=$1
    zipname="${foldername}.zip"
    if [ -d "$foldername" ]; then
        # The folder exists, so create a ZIP archive of its contents
        cd "$foldername"
        zip -r "../$zipname" .
        cd ..
        echo "Created ZIP archive $zipname"
    else
        echo "Error: Folder '$foldername' does not exist"
        return 1
    fi
}

function gh-clone() {
    git_url="$1"
    username=$(echo "$git_url" | sed -E 's/.*github.com:([^/]+)\/.*/\1/')
    repo_name=$(echo "$git_url" | sed -E 's/.*\/([^/]+)\.git/\1/')

    target_dir="$HOME/github.com/$username/$repo_name"

    mkdir -p "$target_dir"
    git clone "$git_url" "$target_dir"
}

function gh-list() {
    base_dir="$HOME/github.com"
    find "$base_dir" -mindepth 2 -maxdepth 2 -type d -printf '%P\n' | sort
}

function gh-cd() {
    cd $HOME/github.com/$(gh-list | fzf)
}

# Copied from https://github.com/jordanlewis/config/blob/master/zshrc
# {{{ GIT heart FZF
function is_in_git_repo() {
    git rev-parse HEAD > /dev/null 2>&1
}

function fzf-down() {
    fzf --height 50% "$@" --border
}

# Untracked files
function gu() {
    git -C "$(git rev-parse --show-toplevel)" status --porcelain --untracked-files=all | grep "^??" | awk '/^??/ {print $2}'
}

function gc { git commit -m "$*"; }

function gf() {
    is_in_git_repo || return
    git -c color.status=always status --short |
        fzf-down -m --ansi --nth 2..,.. \
        --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
        cut -c4- | sed 's/.* -> //'
}
    # }}}

function check_syncthing() {
    running=`ps ax | grep -v grep | grep syncthing | wc -l`
    if [ $running -le 1 ]; then
        echo "🚨 syncthing is not running 🚨"
    fi
}
# zprof
