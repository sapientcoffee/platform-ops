# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# I use oh-my-zsh - Path to installation.
export ZSH=$HOME/.oh-my-zsh


ZSH_THEME="powerlevel10k/powerlevel10k"


# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="false"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Uncomment the following line to disable colors in ls.
DISABLE_LS_COLORS="false"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"



# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(aws brew colorize docker docker-compose cake git github gitignore go iwhois sublime osx git-flow git-extras git-prompt npm osx pip pyenv python screen ssh-agent sudo vagrant virtualenv colored-man-pages node theme web-search battery sublime)
#iplugins=(aws brew colorize docker docker-compose cake git go iwhois osx osx pip pyenv python screen ssh-agent sudo vagrant virtualenv colored-man-pages theme web-search battery)
# Taken out zsh-autosuggestions
#plugins=(fly cf bosh colorize docker docker-compose git github gitignore git-flow git-extras git-prompt npm pip pyenv python ssh-agent sudo vagrant virtualenv colored-man-pages node theme web-search)
plugins=(
  docker  
  git 
  github 
  gitignore 
  git-flow 
  git-extras 
  git-prompt 
  pip 
  pyenv 
  python 
  sudo 
  colored-man-pages 
  theme 
  web-search  
  zsh-syntax-highlighting
  zsh-autosuggestions
)

# User configuration

# History management
export HISTSIZE=25000
export HISTFILE=~/.zsh_history
export SAVEHIST=10000
#setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# =======================
# Environment and Aliases
# =======================

# If a command takes longer than 15 seconds, print its duration
export REPORTTIME=15
# Meh, shit happens:
alias 'cd..=cd ..'
# Common shortcuts
alias ls='ls --color=auto'
alias ll='ls -lrta'
alias l='ls -CF'

# For Git
alias 'gk=z gitk --all'
alias 'gs=git status' # (NB overriding GhostScript)
alias 'gd=git diff'
alias 'gg=z git gui'
alias 'git-stashpullpop=git stash && git pull --rebase && git stash pop'
alias 'gl=git log --graph --abbrev-commit --pretty=oneline --decorate'

# For convenience
alias 'mkdir=mkdir -p'
alias 'dmesg=dmesg --ctime'
alias 'df=df --exclude-type=tmpfs'
alias 'dus=du -msc * .*(N) | sort -n'
alias 'dus.=du -msc .* | sort -n'
alias 'fcs=(for i in * .*(N); do echo $(find $i -type f | wc -l) "\t$i"; done) | sort -n'
alias 'fcs.=(for i in .*; do echo $(find $i -type f | wc -l) "\t$i"; done) | sort -n'
alias 'last=last -a'
alias 'zap=clear; echo -en "\e[3J"'
alias 'rmedir=rmdir -v **/*(/^F)'
alias 'xmlindent=xmlindent -t -f -nbe'

## for k8s
alias k=kubectl
alias kg=kubectl get
alias kgdep=kubectl get deployment
alias ksys=kubectl --namespace=kube-system
alias kd=kubectl describe

## Log file viewing
lastlogdir=logs
alias taillast='tail -f $lastlogdir/*(om[1])'
alias catlast='< $lastlogdir/*(om[1])'
alias lesslast='less $lastlogdir/*(om[1])'

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
#============================================================
bindkey '^R' history-incremental-search-backward
bindkey "^E" vi-end-of-line
bindkey "^A" vi-beginning-of-line


# To customize prompt, run `p10k configure` or edit ~/.zshrc.
[[ ! -f ~/.zshrc ]] || source ~/.zshrc