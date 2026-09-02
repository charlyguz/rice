# ============================================================
#  Herramientas modernas. Debian renombra algunos binarios
#  porque el nombre corto ya estaba cogido:
#    bat -> batcat     ·     fd -> fdfind
#  Estos alias devuelven los nombres de siempre.
# ============================================================
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'

# bat como paginador de manpages y de --help
if command -v batcat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
  export MANROFFOPT="-c"
  ayuda() { "$@" --help 2>&1 | batcat -l help -p; }
fi

# sustitutos directos
command -v dust  >/dev/null 2>&1 && alias du='dust'
command -v procs >/dev/null 2>&1 && alias ps='procs'
command -v ncdu  >/dev/null 2>&1 && alias discos='ncdu'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

# yazi: 'y' entra y, al salir, deja el shell en la carpeta donde estabas.
# aliases-comunes.zsh ya define `alias y='yazi'`, y en zsh no se puede definir
# una función con el mismo nombre que un alias existente: da
# "parse error near ()" y se cae el fichero entero. Por eso se quita antes.
# Fuera del if a propósito: zsh parsea el bloque entero antes de ejecutar
# nada, así que un unalias DENTRO llega tarde y el parseo ya ha fallado.
unalias y 2>/dev/null
if command -v yazi >/dev/null 2>&1; then
  y() {
    local tmp cwd; tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd" || true
    fi
    rm -f -- "$tmp"
  }
fi

# atuin: sustituye Ctrl+R por un historial buscable.
# Va al final para que sus atajos ganen a los de zsh.
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# 'fastfetch' a secas usa su config (logo ASCII pequeño). Quien quiere las
# imágenes al azar es rice-fetch. Se aliasa para que dé igual cuál escribas;
# con 'command fastfetch' sigues teniendo el original.
if [ -x "$HOME/.local/bin/rice-fetch" ]; then
  alias fastfetch="$HOME/.local/bin/rice-fetch"
  alias ff="$HOME/.local/bin/rice-fetch"
fi

# ---------- herramientas añadidas después ----------
# Papelera en vez de borrado definitivo. 'rm' se deja intacto a propósito:
# si un script llama a rm, tiene que borrar de verdad.
command -v trash-put >/dev/null 2>&1 && {
  alias tr-put='trash-put'
  alias papelera='trash-list'
  alias papelera-vaciar='trash-empty'
  alias papelera-restaurar='trash-restore'
}
command -v hx    >/dev/null 2>&1 && alias e='hx'          # editor rápido
command -v nvim  >/dev/null 2>&1 && alias vim='nvim'
command -v xh    >/dev/null 2>&1 && alias http='xh'
command -v glow  >/dev/null 2>&1 && alias md='glow -p'    # leer markdown
command -v w3m   >/dev/null 2>&1 && alias web='w3m'
command -v broot >/dev/null 2>&1 && alias br='broot'
command -v gping >/dev/null 2>&1 && alias ping-g='gping'
command -v tty-clock >/dev/null 2>&1 && alias reloj='tty-clock -c -C 4 -s -b'

# direnv: carga variables al entrar en una carpeta. Al final, como pide su doc.
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
