
alias fetch="/Users/Chris/animFetch -happy"
alias termstartmac="/Users/Chris/mac.sh"
# termstartmac
fastfetch
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export TERM=xterm-256color
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$PATH:/Users/chris/.spicetify
genpass() {
  while true; do
    pass=$(openssl rand -base64 48 | tr -dc 'A-Za-z0-9!@#%^*_+=-[]{}<>?' | head -c32)
    if [[ "$pass" == *[A-Z]* ]]; then
      if [[ "$pass" == *[a-z]* ]]; then
        if [[ "$pass" == *[0-9]* ]]; then
          if [[ "$pass" == *[!@#%^*_+=\-\[\]{}?]* ]]; then
            echo "Generated password: $pass"
            break
          fi
        fi
      fi
    fi
  done

  read -q "save?Save this password encrypted to your Safe folder? (y/n): "
  echo
  if [[ "$save" =~ ^[Yy]$ ]]; then
    safe_dir="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Safe"
    mkdir -p "$safe_dir"

    # Prompt for file name with default fallback
    read -r "filename?Enter filename (without extension) [default: password_$(date +%Y%m%d_%H%M%S)]: "
    if [[ -z "$filename" ]]; then
      filename="password_$(date +%Y%m%d_%H%M%S)"
    fi

    # Sanitize filename: remove or replace problematic characters (optional)
    filename="${filename//[^a-zA-Z0-9._-]/_}"

    filepath="$safe_dir/$filename.enc"

    echo -n "$pass" | openssl enc -aes-256-cbc -salt -pbkdf2 -out "$filepath"
    if [[ $? -eq 0 ]]; then
      echo "Password saved encrypted at: $filepath"
    else
      echo "Error saving password."
    fi
  else
    echo "Password not saved."
  fi
}
openpass() {
  local safe_dir="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Safe"
  local file

  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed. Install it with: brew install fzf"
    return 1
  fi

  if [[ ! -d "$safe_dir" ]]; then
    echo "Safe folder does not exist: $safe_dir"
    return 1
  fi

  # List .enc files and select one with fzf
  file=$(ls "$safe_dir"/*.enc 2>/dev/null | fzf --prompt="Select a password file: ")
  if [[ -z "$file" ]]; then
    echo "No file selected."
    return 1
  fi

  echo "Decrypting $file ..."
  openssl enc -d -aes-256-cbc -pbkdf2 -in "$file"
}
thisisnotacommand(){
	echo "this is a command"
}
minecraft-server() {
  ssh chris@192.168.69.69 -t 'tmux attach -t mcserver || tmux new -s mcserver'
}

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/chris/.lmstudio/bin"
# End of LM Studio CLI section


# Added by Antigravity
export PATH="/Users/chris/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/chris/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/chris/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/chris/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/chris/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity
export PATH="/Users/chris/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity IDE
export PATH="/Users/chris/.antigravity-ide/antigravity-ide/bin:$PATH"
