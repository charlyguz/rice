#!/usr/bin/env bash
# Deshace el cambio: mata Waybar y devuelve la barra de Noctalia.
set -euo pipefail

CONF="$HOME/.config/noctalia/config.toml"

pkill waybar 2>/dev/null || true
echo "✓ Waybar detenido"

if [ -f "$CONF.bak-waybar" ]; then
  cp "$CONF.bak-waybar" "$CONF"
  echo "✓ Config de Noctalia restaurado desde el respaldo"
else
  sed -i '/^enabled = false$/d' "$CONF"
  echo "✓ Barra de Noctalia reactivada"
fi

echo
echo "Quita también la línea de waybar en:"
echo "  ~/.config/hypr/config/autostart.lua"
