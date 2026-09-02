#!/usr/bin/env bash
# ============================================================
#  Tema Fallout para GRUB.
#  Original: https://github.com/shvchk/fallout-grub-theme (MIT)
#
#  Se instala a mano en vez de con su install.sh porque aquel
#  vuelve a descargar el tarball y pide el idioma por un menú
#  interactivo, que sin terminal se cuelga.
# ============================================================
set -uo pipefail
REPO="${REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$REPO/lib/comun.sh" 2>/dev/null || { ok(){ echo "  ✓ $*"; }; warn(){ echo "  ! $*"; }; info(){ echo "  $*"; }; step(){ echo "▸ $*"; }; have(){ command -v "$1" >/dev/null 2>&1; }; }
DRY="${DRY:-0}"
PATH="/usr/sbin:/sbin:$PATH"

step "Tema de GRUB (Fallout)"
[ -d /boot/grub ] || { info "no hay GRUB aquí: me lo salto"; exit 0; }
have update-grub || have grub-mkconfig || { warn "sin update-grub/grub-mkconfig: me lo salto"; exit 0; }
[ "$DRY" = 1 ] && { info "(dry-run) instalaría el tema Fallout en /boot/grub/themes"; exit 0; }

T=/boot/grub/themes/fallout-grub-theme
sudo mkdir -p "$T"
sudo cp -r "$REPO"/base/grub/fallout-grub-theme/* "$T"/ || { warn "no pude copiar el tema"; exit 0; }

# respaldo antes de tocar el arranque
sudo cp -a /etc/default/grub "/etc/default/grub.bak-$(date +%Y%m%d-%H%M%S)" 2>/dev/null

sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
sudo sed -i 's/^\(GRUB_TERMINAL\w*=.*\)/#\1/' /etc/default/grub     # que use salida gráfica
sudo sed -i '/^#\?GRUB_GFXMODE=/d' /etc/default/grub
printf 'GRUB_GFXMODE=1920x1080,1280x720,auto\nGRUB_THEME=%s/theme.txt\n' "$T" | sudo tee -a /etc/default/grub >/dev/null

# En Debian, 05_debian_theme pone su propio background_image DESPUÉS del
# 'set theme', y pisa el fondo del tema. Se desactiva (chmod +x lo revierte).
if [ -x /etc/grub.d/05_debian_theme ]; then
  sudo chmod -x /etc/grub.d/05_debian_theme && info "05_debian_theme desactivado (pisaba el fondo)"
fi

if have update-grub; then sudo update-grub >/dev/null 2>&1
else sudo grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1; fi

if sudo grub-script-check /boot/grub/grub.cfg 2>/dev/null; then
  ok "tema Fallout instalado y grub.cfg válido"
else
  warn "grub.cfg no valida: revisa antes de reiniciar"
fi
