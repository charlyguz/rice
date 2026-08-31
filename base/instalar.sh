#!/usr/bin/env bash
# ============================================================
#  base/instalar.sh — lo que es igual en Arch y en Debian:
#  shell, apps de terminal, fuentes, cursor y colores.
#  Lo llama install.sh, pero funciona suelto.
# ============================================================
set -uo pipefail
REPO="${REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$REPO/lib/comun.sh"
CFG="${CFG:-${XDG_CONFIG_HOME:-$HOME/.config}}"
DATA="${DATA:-${XDG_DATA_HOME:-$HOME/.local/share}}"
BIN="${BIN:-$HOME/.local/bin}"
BACKUP="${BACKUP:-$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)}"
DRY="${DRY:-0}"; ASSUME_YES="${ASSUME_YES:-0}"; export DRY ASSUME_YES
detect_distro
guardar() { [ -e "$1" ] || return 0; local rel="${1#"$HOME"/}"; run mkdir -p "$BACKUP/$(dirname "$rel")"; run cp -a "$1" "$BACKUP/$rel" 2>/dev/null || true; }
poner() { # poner <origen> <destino>
  [ "$DRY" = 1 ] && { info "(dry-run) $2"; return; }
  guardar "$2"; mkdir -p "$(dirname "$2")"; cp -a "$1" "$2"
}

step "Shell: zsh"
poner "$REPO/base/zsh/zshrc"    "$HOME/.zshrc"
poner "$REPO/base/zsh/p10k.zsh" "$HOME/.p10k.zsh"
mkdir -p "$CFG/zsh"
for a in "$REPO"/base/zsh/aliases-*.zsh; do poner "$a" "$CFG/zsh/$(basename "$a")"; done
ok ".zshrc + .p10k.zsh (1840 líneas, el tuyo) + alias por distro"

if [ "$DRY" = 0 ]; then
  # oh-my-zsh: en CachyOS vive en /usr/share; en Debian hay que clonarlo
  if [ ! -d /usr/share/oh-my-zsh ] && [ ! -d "$DATA/oh-my-zsh" ] && [ ! -d "$HOME/.oh-my-zsh" ]; then
    if have git && ask "oh-my-zsh no está. ¿Lo clono? (lo usan tus plugins git/fzf/extract)" y; then
      gclone https://github.com/ohmyzsh/ohmyzsh.git "$DATA/oh-my-zsh" \
        && ok "oh-my-zsh clonado" || warn "no pude clonar oh-my-zsh (¿sin red?)"
    fi
  else ok "oh-my-zsh ya está"; fi

  # powerlevel10k y plugins: usar los del sistema, clonar lo que falte
  tiene_p10k=0
  for d in /usr/share/zsh-theme-powerlevel10k /usr/share/powerlevel10k "$DATA/zsh/powerlevel10k"; do
    [ -f "$d/powerlevel10k.zsh-theme" ] && tiene_p10k=1
  done
  if [ "$tiene_p10k" = 0 ]; then
    mkdir -p "$DATA/zsh"
    gclone https://github.com/romkatv/powerlevel10k.git "$DATA/zsh/powerlevel10k" \
      && ok "powerlevel10k clonado" || { warn "sin powerlevel10k"; MISSING+=(powerlevel10k); }
  else [ "$tiene_p10k" = 1 ] && ok "powerlevel10k del sistema"; fi

  for pl in zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search; do
    f=0
    for d in "/usr/share/zsh/plugins/$pl" "/usr/share/$pl" "$DATA/zsh/$pl"; do [ -f "$d/$pl.zsh" ] && f=1; done
    if [ "$f" = 0 ]; then
      mkdir -p "$DATA/zsh"
      gclone "https://github.com/zsh-users/$pl.git" "$DATA/zsh/$pl" && ok "$pl (clonado)"
    fi
  done

  if have zsh && [ "$SHELL" != "$(command -v zsh)" ]; then
    ask "¿Pongo zsh como tu shell por defecto?" y && \
      { sudo chsh -s "$(command -v zsh)" "$USER" && ok "zsh por defecto (al reiniciar sesión)"; }
  fi
fi

step "Apps de terminal"
poner "$REPO/base/kitty/kitty.conf"          "$CFG/kitty/kitty.conf"
poner "$REPO/base/btop/btop.conf"            "$CFG/btop/btop.conf"
poner "$REPO/base/micro/settings.json"       "$CFG/micro/settings.json"
poner "$REPO/base/micro/bindings.json"       "$CFG/micro/bindings.json"
poner "$REPO/base/starship.toml"             "$CFG/starship.toml"
poner "$REPO/base/alacritty/alacritty.toml"  "$CFG/alacritty/alacritty.toml"
poner "$REPO/base/fastfetch/config.jsonc"    "$CFG/fastfetch/config.jsonc"
if [ "$DRY" = 0 ] && [ -d "$REPO/base/micro/colorschemes" ]; then
  mkdir -p "$CFG/micro/colorschemes"; cp -f "$REPO"/base/micro/colorschemes/* "$CFG/micro/colorschemes/" 2>/dev/null
fi
ok "kitty, btop, micro, starship, alacritty, fastfetch"

step "GTK y carpetas"
poner "$REPO/base/gtk-3.0/settings.ini" "$CFG/gtk-3.0/settings.ini"
poner "$REPO/base/gtk-3.0/gtk.css"      "$CFG/gtk-3.0/gtk.css"
poner "$REPO/base/gtk-4.0/settings.ini" "$CFG/gtk-4.0/settings.ini"
poner "$REPO/base/gtk-4.0/gtk.css"      "$CFG/gtk-4.0/gtk.css"
# carpetas del home en español, como las tenías
poner "$REPO/base/xdg/user-dirs.dirs"   "$CFG/user-dirs.dirs"
[ "$DRY" = 0 ] && have xdg-user-dirs-update && xdg-user-dirs-update >/dev/null 2>&1
ok "GTK + carpetas en español"

step "Git"
if [ "$DRY" = 0 ] && [ ! -f "$HOME/.gitconfig" ]; then
  cp "$REPO/base/git/gitconfig" "$HOME/.gitconfig"; ok ".gitconfig (nombre, correo y gh como credential helper)"
else info "ya tenías .gitconfig: no lo toco"; fi

step "Comandos y paletas"
if [ "$DRY" = 0 ]; then
  mkdir -p "$BIN"
  for f in "$REPO"/bin/* "$REPO"/temas/bin/*; do [ -f "$f" ] && { chmod +x "$f"; cp -f "$f" "$BIN/$(basename "$f")"; }; done
  case "${PERFIL:-}" in
    hyprland) for f in "$REPO"/perfiles/hyprland/bin/*; do [ -f "$f" ] && { chmod +x "$f"; cp -f "$f" "$BIN/$(basename "$f")"; }; done ;;
    plasma)   for f in "$REPO"/perfiles/plasma/bin/*;   do [ -f "$f" ] && { chmod +x "$f"; cp -f "$f" "$BIN/$(basename "$f")"; }; done ;;
  esac
  ok "$(find "$BIN" -maxdepth 1 -name "rice-*" | wc -l) comandos rice-* en $BIN"
  rm -rf "$DATA/rice/palettes"; mkdir -p "$DATA/rice"
  cp -a "$REPO/temas/paletas" "$DATA/rice/palettes"
  mkdir -p "$CFG/rice"
fi

step "Fuentes y cursor"
if [ "$DRY" = 0 ]; then
  mkdir -p "$DATA/fonts/rice"; cp -f "$REPO"/assets/fonts/*.ttf "$DATA/fonts/rice/" 2>/dev/null && ok "Outfit, Rubik, Lexend, Nunito"
  if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
    T=$(mktemp -d)
    if dl "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "$T/j.zip"; then
      mkdir -p "$DATA/fonts/JetBrainsMonoNerd"
      unzip -qo "$T/j.zip" -d "$DATA/fonts/JetBrainsMonoNerd" '*.ttf' 2>/dev/null && ok "JetBrainsMono Nerd Font"
    else warn "no pude bajar la Nerd Font"; MISSING+=("JetBrainsMono Nerd Font"); fi
    rm -rf "$T"
  else info "ya estaba: JetBrainsMono Nerd Font"; fi
  # MesloLGS Nerd: es la que pide tu p10k
  if ! fc-list 2>/dev/null | grep -qi "MesloLGS"; then
    T=$(mktemp -d)
    if dl "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip" "$T/m.zip"; then
      mkdir -p "$DATA/fonts/MesloNerd"
      unzip -qo "$T/m.zip" -d "$DATA/fonts/MesloNerd" '*.ttf' 2>/dev/null && ok "Meslo Nerd Font (la que usa tu p10k)"
    fi
    rm -rf "$T"
  fi
  if [ ! -d "$DATA/icons/Bibata-Modern-Ice" ] && [ ! -d /usr/share/icons/Bibata-Modern-Ice ]; then
    T=$(mktemp -d)
    U="https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"
    dl "$U" "$T/b.tar.xz" 2>/dev/null || U=$(gh_latest_asset ful1e5/Bibata_Cursor "Bibata-Modern-Ice.tar.xz" 2>/dev/null || true)
    if [ -s "$T/b.tar.xz" ] || { [ -n "${U:-}" ] && dl "$U" "$T/b.tar.xz" 2>/dev/null; }; then
      mkdir -p "$DATA/icons"; tar -xf "$T/b.tar.xz" -C "$DATA/icons" && ok "cursor Bibata-Modern-Ice"
    else warn "no pude bajar el cursor"; MISSING+=(Bibata-Modern-Ice); fi
    rm -rf "$T"
  else info "ya estaba: Bibata-Modern-Ice"; fi
  mkdir -p "$HOME/.icons/default"
  printf '[Icon Theme]\nName=Default\nInherits=Bibata-Modern-Ice\n' > "$HOME/.icons/default/index.theme"
  fc-cache -f >/dev/null 2>&1
fi

step "Fondos y tema"
if [ "$DRY" = 0 ]; then
  mkdir -p "$HOME/Imágenes/Wallpapers" "$HOME/Pictures/Wallpapers" 2>/dev/null
  W="$HOME/Imágenes/Wallpapers"; [ -d "$HOME/Imágenes" ] || W="$HOME/Pictures/Wallpapers"
  cp -n "$REPO"/wallpapers/* "$W/" 2>/dev/null || true
  ok "$(ls -1 "$W" 2>/dev/null | wc -l) fondos en $W"
  PAL=$(cat "$CFG/rice/current-palette" 2>/dev/null || echo tokyonight)
  PATH="$BIN:$PATH" rice-theme "$PAL" >/dev/null 2>&1 && ok "paleta: $PAL" || warn "aplica el tema a mano: rice-theme tokyonight"
fi
