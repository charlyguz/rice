#!/usr/bin/env bash
# Perfil KDE Plasma (Debian): lo mismo, traducido.
set -uo pipefail
REPO="${REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$REPO/lib/comun.sh"; source "$REPO/lib/paquetes.sh"; source "$REPO/lib/hardware.sh"
CFG="${CFG:-$HOME/.config}"; DATA="${DATA:-$HOME/.local/share}"
BACKUP="${BACKUP:-$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)}"
DRY="${DRY:-0}"; ASSUME_YES="${ASSUME_YES:-0}"; export DRY ASSUME_YES
detect_distro
P="$REPO/perfiles/plasma"
guardar() { [ -e "$1" ] || return 0; mkdir -p "$BACKUP/.config"; cp -a "$1" "$BACKUP/.config/" 2>/dev/null || true; }

step "Escritorio KDE Plasma"
if ! have plasmashell; then
  warn "Plasma no está instalado."
  if [ "${DO_PAQUETES:-1}" = 1 ] && ask "¿Instalo el escritorio KDE completo? (descarga grande)" y; then
    mapfile -t B < <(plasma_base); pkg_install "${B[@]}"
    [ "$DRY" = 0 ] && sudo systemctl enable sddm >/dev/null 2>&1
  fi
else ok "Plasma $(plasmashell --version 2>/dev/null | awk '{print $2}')"; fi
[ "${DO_PAQUETES:-1}" = 1 ] && { mapfile -t K < <(pkgs_plasma); pkg_install "${K[@]}"; }

[ "$DRY" = 1 ] && { info "(dry-run) ajustes, atajos, tema y panel de Plasma"; exit 0; }

step "Widgets propios"
# El reloj de Plasma pone SIEMPRE la hora en grande y no deja invertirlo,
# así que el reloj de escritorio (día grande, fecha y hora debajo) es un
# plasmoide propio. Es QML: no hay que descargar nada.
if [ -d "$P/plasmoids" ]; then
  mkdir -p "$DATA/plasma/plasmoids"
  for w in "$P"/plasmoids/*/; do
    [ -d "$w" ] || continue
    n=$(basename "$w")
    rm -rf "$DATA/plasma/plasmoids/$n"
    cp -a "$w" "$DATA/plasma/plasmoids/$n" && ok "widget $n"
  done
  have kbuildsycoca6 && kbuildsycoca6 --noincremental >/dev/null 2>&1
fi

step "Tema de escritorio"
mkdir -p "$DATA/plasma/desktoptheme"
rm -rf "$DATA/plasma/desktoptheme/Rice"
cp -a "$P/desktoptheme/Rice" "$DATA/plasma/desktoptheme/Rice"
ok "tema 'Rice' (panel translúcido y redondeado)"

if have kwriteconfig6 || have kwriteconfig5; then
  step "Ajustes y atajos"
  for f in kdeglobals kwinrc breezerc plasmarc klipperrc dolphinrc spectaclerc \
           kscreenlockerrc ksmserverrc kcminputrc kglobalshortcutsrc; do guardar "$CFG/$f"; done
  RICE_ICONS=Papirus-Dark RICE_CURSOR=Bibata-Modern-Ice RICE_UI_FONT=Outfit \
    RICE_MONO_FONT="JetBrainsMono Nerd Font" bash "$P/apply-settings.sh" 2>&1 | sed 's/^/  /'
  bash "$P/shortcuts.sh" 2>&1 | sed 's/^/  /'
  # shortcuts.sh solo escribe el fichero, y KDE lo machaca al salir además de
  # rechazar las teclas ya ocupadas. rice-shortcuts las aplica por D-Bus,
  # liberando antes al ocupante, que es lo que de verdad las deja puestas.
  if pgrep -x plasmashell >/dev/null 2>&1; then
    bash "$REPO/bin/rice-shortcuts" 2>&1 | sed 's/^/  /'
  else
    info "Plasma no corre: al entrar a tu sesión ejecuta  rice-shortcuts"
  fi
  if have kwriteconfig6; then kwriteconfig6 --file plasmarc --group Theme --key name Rice; fi
  have plasma-apply-cursortheme && plasma-apply-cursortheme Bibata-Modern-Ice >/dev/null 2>&1 || true
  if [ ! -s "$CFG/kwinrulesrc" ]; then cp "$P/kwinrules.conf" "$CFG/kwinrulesrc"; ok "reglas de ventana"; fi
else
  warn "sin kwriteconfig6: instala Plasma y vuelve a correr ./install.sh --debian"
fi

step "Panel"
if pgrep -x plasmashell >/dev/null 2>&1; then
  guardar "$CFG/plasma-org.kde.plasma.desktop-appletsrc"
  if have gdbus; then
    out=$(gdbus call --session --dest org.kde.plasmashell --object-path /PlasmaShell \
          --method org.kde.PlasmaShell.evaluateScript "$(cat "$P/panel.js")" 2>&1) || true
    case "$out" in *[Ee]rror*) warn "Plasma dijo: $out" ;; *) ok "panel reconstruido" ;; esac
  else warn "sin gdbus: corre  rice-panel  dentro de tu sesión"; fi
else
  warn "Plasma no corre ahora: cuando entres a tu sesión corre  rice-panel"
fi
echo fuzzel > "$CFG/rice/menu" 2>/dev/null || true
