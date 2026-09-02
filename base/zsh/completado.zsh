# ============================================================
#  Autocompletado inteligente
#
#  Orden importante: esto va DESPUÉS de compinit y ANTES de
#  zsh-autosuggestions y zsh-syntax-highlighting, porque esos
#  dos envuelven widgets y fzf-tab necesita envolverlos antes.
# ============================================================

# 191 definiciones extra (docker, kubectl, cargo, gh...)
if [[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh-completions/src" ]]; then
  fpath=("${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh-completions/src" $fpath)
fi

# compinit con caché diaria: sin esto arranca notablemente más lento
autoload -Uz compinit
_zcd="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
if [[ -n $_zcd(#qN.mh+24) ]]; then compinit -d "$_zcd"; else compinit -C -d "$_zcd"; fi
unset _zcd

zmodload zsh/complist

# --- cómo se busca ---
# 1) tal cual  2) sin distinguir mayúsculas  3) por trozos: 'cn/co/pl' -> 'config/corp/plugins'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric   # tolera 2 erratas

# --- cómo se ve ---
zstyle ':completion:*' menu no                     # lo sustituye fzf-tab
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{#7aa2f7}%B %d%b%f'
zstyle ':completion:*:messages'     format '%F{#bb9af7} %d%f'
zstyle ':completion:*:warnings'     format '%F{#f7768e} sin resultados%f'
zstyle ':completion:*:corrections'  format '%F{#e0af68} %d (errores: %e)%f'

# --- comportamiento ---
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zcompcache"
zstyle ':completion:*' special-dirs true           # completa . y ..
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories

setopt AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END PATH_DIRS
setopt AUTO_PARAM_SLASH NO_CASE_GLOB
unsetopt MENU_COMPLETE FLOW_CONTROL

# --- fzf-tab: el menú de completado pasa a ser un buscador ---
_ftab="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/fzf-tab/fzf-tab.plugin.zsh"
if [[ -r "$_ftab" ]]; then
  source "$_ftab"

  zstyle ':fzf-tab:*' fzf-flags --height=45% --layout=reverse --border=rounded \
    --color=bg+:#292e42,bg:#1a1b26,spinner:#bb9af7,hl:#7aa2f7 \
    --color=fg:#c0caf5,header:#7aa2f7,info:#e0af68,pointer:#bb9af7 \
    --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7aa2f7
  zstyle ':fzf-tab:*' switch-group ',' '.'
  zstyle ':fzf-tab:*' prefix ''
  zstyle ':fzf-tab:*' single-group color header

  # vista previa al movnerse por el menú
  if command -v eza >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:cd:*'       fzf-preview 'eza -1 --color=always --icons $realpath'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
  fi
  if command -v batcat >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:*:*' fzf-preview \
      '[[ -d $realpath ]] && { command -v eza >/dev/null && eza -1 --color=always --icons $realpath || ls -1 $realpath; } || batcat --color=always --style=numbers --line-range=:80 $realpath 2>/dev/null'
  fi
  # variables de entorno y procesos, también con vista previa
  zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'
  zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    '[[ $group == "[proceso]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
fi
unset _ftab
