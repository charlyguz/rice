# Alias que funcionan igual en cualquier distro.
# Vienen de tu config de CachyOS; los que dependían de pacman están
# en aliases-arch.zsh / aliases-debian.zsh.

alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias n="ninja"
alias c="clear"
alias please="sudo"
alias tb="nc termbin.com 9999"
alias jctl="journalctl -p 3 -xb"          # solo los errores del arranque

alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'
alias ip='ip -color=auto'

# Herramientas modernas si están instaladas, si no las de siempre
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lh --icons --group-directories-first --git'
  alias la='eza -lha --icons --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons'
else
  alias ls='ls --color=auto'
  alias ll='ls -lh --color=auto'
  alias la='ls -lha --color=auto'
fi
command -v bat  >/dev/null 2>&1 && alias cat='bat --paging=never --style=plain'
command -v duf  >/dev/null 2>&1 && alias df='duf'
command -v yazi >/dev/null 2>&1 && alias y='yazi'
alias e='$EDITOR'
