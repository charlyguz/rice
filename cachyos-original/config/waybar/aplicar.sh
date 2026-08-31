#!/usr/bin/env bash
# Cambia la barra de Noctalia por Waybar.
# Uso:  ~/.config/waybar/aplicar.sh
# Para deshacer: ~/.config/waybar/revertir.sh

set -euo pipefail

CONF="$HOME/.config/noctalia/config.toml"

if ! command -v waybar >/dev/null 2>&1; then
  echo "✗ Waybar no está instalado. Corre primero:"
  echo "    sudo pacman -S waybar"
  exit 1
fi

# Respaldo del config de Noctalia (una sola vez)
if [ ! -f "$CONF.bak-waybar" ]; then
  cp "$CONF" "$CONF.bak-waybar"
  echo "✓ Respaldo: $CONF.bak-waybar"
fi

# Apaga la barra de Noctalia (el resto de Noctalia sigue vivo:
# notificaciones, launcher, control center, lockscreen).
if grep -q '^enabled = false' "$CONF"; then
  echo "· La barra de Noctalia ya estaba apagada"
else
  sed -i 's/^\[bar\.default\]$/[bar.default]\nenabled = false/' "$CONF"
  echo "✓ Barra de Noctalia apagada"
fi

# Lanza Waybar
pkill waybar 2>/dev/null || true
sleep 1
waybar >/dev/null 2>&1 &
disown
echo "✓ Waybar corriendo"
echo
echo "Si algo se ve mal:  ~/.config/waybar/revertir.sh"
