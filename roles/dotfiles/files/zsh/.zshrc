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
alias install='distrobox-enter arch-dev-box -- yay -S'
alias update='distrobox-enter arch-dev-box -- yay -Syu'
alias search='distrobox-enter arch-dev-box -- yay -Ss'
alias remove='distrobox-enter arch-dev-box -- yay -Rns'

# v4.0 Aliases (Host UI vs Dev Box)
alias nv='distrobox-enter arch-dev-box -- nvim'
alias edit='distrobox-enter arch-dev-box -- nvim'
alias lg='distrobox-enter arch-dev-box -- lazygit'
alias ld='distrobox-enter arch-dev-box -- lazydocker'
alias sys='btop'

# v4.0 Bubble (Containerized Hermetic Env Creator)
bubble() {
  if [ "$1" = "p" ]; then
    # Python / Poetry Bubble (Inicia config e abre Shell no Contentor)
    if [ ! -f .tool-versions ]; then
      echo "python system" > .tool-versions
      echo "poetry system" >> .tool-versions
    fi
    echo "layout poetry" > .envrc
    echo "🫧 Bubble: Ambientes Python configurados."
    echo "🚀 A entrar no teu Arch-Dev-Box..."
    distrobox-enter arch-dev-box
    
  elif [ "$1" = "l" ]; then
    # Laravel / PHP Bubble (Inicia config e abre Shell no Contentor)
    if [ ! -f .tool-versions ]; then
      echo "php system" > .tool-versions
    fi
    echo "use asdf" > .envrc
    echo "🫧 Bubble: Ambientes Laravel configurados."
    echo "🚀 A entrar no teu Arch-Dev-Box..."
    distrobox-enter arch-dev-box
    
  else
    echo "Usage: bubble [p|l]"
    echo "  p = Python (Poetry)"
    echo "  l = Laravel (PHP)"
  fi
}

# Dev Aliases (Sem-Emenda para o Container)
alias artisan='distrobox-enter arch-dev-box -- php artisan'
alias serve='distrobox-enter arch-dev-box -- php artisan serve'
alias migrate='distrobox-enter arch-dev-box -- php artisan migrate'
alias fresh='distrobox-enter arch-dev-box -- php artisan migrate:fresh --seed'
alias tinker='distrobox-enter arch-dev-box -- php artisan tinker'
alias py='distrobox-enter arch-dev-box -- python'
alias php='distrobox-enter arch-dev-box -- php'
alias composer='distrobox-enter arch-dev-box -- composer'
alias p='distrobox-enter arch-dev-box -- poetry'
alias pr='distrobox-enter arch-dev-box -- poetry run'
alias ps='distrobox-enter arch-dev-box -- poetry shell'
alias pa='distrobox-enter arch-dev-box -- poetry add'
alias flet-run='distrobox-enter arch-dev-box -- poetry run flet run'
alias flask-dev='export FLASK_DEBUG=1 && distrobox-enter arch-dev-box -- poetry run flask run'

# 6. MODERN TOOLS & FZF
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# 6.1 ASDF (Version Manager)
if [ -f /opt/asdf-vm/asdf.sh ]; then
    source /opt/asdf-vm/asdf.sh
fi

# 6.2 DIRENV (Hermetic Environments)
eval "$(direnv hook zsh)"

# 7. STARSHIP
eval "$(starship init zsh)"
