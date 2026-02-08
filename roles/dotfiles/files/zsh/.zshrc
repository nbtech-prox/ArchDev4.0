# 0. PATH
export PATH="$HOME/.config/composer/vendor/bin:$HOME/.local/bin:$PATH"

# GEMINI_API_KEY (Generate a new one at aistudio.google.com)
# To keep it safe, I recommend putting it in a file ~/.gemini_key and sourcing it:
[ -f ~/.gemini_key ] && source ~/.gemini_key

# Enable Powerlevel10k or Starship instant prompt if needed
# ...

# 1. COMPLETION SYSTEM
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive tab completion
compinit
_comp_options+=(globdots)		# Include hidden files.

# 2. HISTORY
HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# 3. KEYBINDINGS (Better navigation)
bindkey -e
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key
# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #

# 4. PLUGINS (Arch Linux Paths)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# 5. ALIASES
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias cat='bat'
alias install='yay -S'
alias update='yay -Syu'
alias search='yay -Ss'
alias remove='yay -Rns'

# v2.0 Aliases
alias nv='nvim'
alias edit='nvim'
alias reload-config='cd ~/.dotfiles && stow -R */ && cd -'
alias lg='lazygit'
alias ld='lazydocker'
alias sys='btop'

# v2.5 Bubble (Hermetic Env Creator)
bubble() {
  if [ "$1" = "p" ]; then
    # Python / Poetry Bubble
    if [ ! -f .tool-versions ]; then
      echo "python system" > .tool-versions
      echo "poetry system" >> .tool-versions
    fi
    echo "layout poetry" > .envrc
    direnv allow
    echo "🫧 Bubble: Poetry environment activated (Python)."
    
  elif [ "$1" = "l" ]; then
    # Laravel / PHP Bubble
    if [ ! -f .tool-versions ]; then
      echo "php system" > .tool-versions
    fi
    echo "use asdf" > .envrc
    direnv allow
    echo "🫧 Bubble: PHP/Laravel environment activated."
    
  else
    echo "Usage: bubble [p|l]"
    echo "  p = Python (Poetry)"
    echo "  l = Laravel (PHP)"
  fi
}

# Dev Aliases
alias artisan='php artisan'
alias serve='php artisan serve'
alias migrate='php artisan migrate'
alias fresh='php artisan migrate:fresh --seed'
alias tinker='php artisan tinker'
alias py='python'
alias p='poetry'
alias pr='poetry run'
alias ps='poetry shell'
alias pa='poetry add'
alias flet-run='poetry run flet run'
alias flask-dev='export FLASK_DEBUG=1 && poetry run flask run'

# 6. MODERN TOOLS & FZF
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# 6.1 DIRENV (Hermetic Environments)
eval "$(direnv hook zsh)"

# 7. STARSHIP
eval "$(starship init zsh)"
