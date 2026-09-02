# ============================================================
#  Sugerencias en gris (zsh-autosuggestions), afinadas.
# ============================================================

# Dos fuentes en vez de una:
#   history    -> lo que ya escribiste alguna vez
#   completion -> lo que el completado sabe (comandos, rutas, flags)
# Con 'completion' hay sugerencia desde el primer día, sin esperar
# a acumular historial.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# El gris de antes (#565f89) casi no se distingue sobre #1a1b26.
# Éste sigue siendo discreto pero se lee.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6b7394'

# No sugerir sobre líneas larguísimas (pegar un comando enorme se nota)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
ZSH_AUTOSUGGEST_USE_ASYNC=1

# --- cómo aceptar la sugerencia ---
#   →  o  End      acepta entera
#   Ctrl+→         acepta solo la palabra siguiente
#   Ctrl+Space     acepta entera (cómodo sin soltar la mano)
bindkey '^[[C'    autosuggest-accept          2>/dev/null   # flecha derecha
bindkey '^[[F'    autosuggest-accept          2>/dev/null   # End
bindkey '^[[1;5C' forward-word                2>/dev/null   # Ctrl+→ palabra
bindkey '^ '      autosuggest-accept          2>/dev/null   # Ctrl+Espacio
