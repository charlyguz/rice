#!/usr/bin/env bash
# Perfil Hyprland (Arch / CachyOS): tu escritorio de siempre, sin Noctalia.
set -uo pipefail
REPO="${REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$REPO/lib/comun.sh"; source "$REPO/lib/paquetes.sh"; source "$REPO/lib/hardware.sh"
CFG="${CFG:-$HOME/.config}"; BIN="${BIN:-$HOME/.local/bin}"
BACKUP="${BACKUP:-$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)}"
DRY="${DRY:-0}"; ASSUME_YES="${ASSUME_YES:-0}"; export DRY ASSUME_YES
detect_distro
P="$REPO/perfiles/hyprland"

step "Escritorio Hyprland"
[ "${DO_PAQUETES:-1}" = 1 ] && { mapfile -t H < <(pkgs_hyprland); pkg_install "${H[@]}"; }
[ "$FAMILY" = arch ] && { ensure_aur >/dev/null 2>&1; aur_install satty swayosd bibata-cursor-theme-bin 2>/dev/null; }

step "Configuración"
GPU=$(gpu_vendor)
if has_backlight; then BL='"backlight",'; else BL=''; fi
if has_battery;   then BT=', "battery"'; else BT=''; fi
TZ=0; for p in x86_pkg_temp k10temp coretemp acpitz; do
  for f in /sys/class/thermal/thermal_zone*/type; do
    [ -r "$f" ] && [ "$(cat "$f")" = "$p" ] && { z="${f%/type}"; TZ="${z##*thermal_zone}"; break 2; }
  done; done
render() { local bl="s|__BACKLIGHT__|$BL|g"; [ -z "$BL" ] && bl='/^[[:space:]]*__BACKLIGHT__[[:space:]]*$/d'
  sed -e "s|__CFG__|$CFG|g" -e "s|__BIN__|$BIN|g" -e "s|__LOGO__|󰣇|g" \
      -e "s|__TZONE__|$TZ|g" -e "$bl" -e "s|__BATTERY__|$BT|g" "$1" > "$2"; }

[ "$DRY" = 1 ] && { info "(dry-run) configuración de Hyprland"; exit 0; }
for d in hypr waybar rofi swaync wlogout uwsm; do
  [ -d "$P/$d" ] || continue
  while IFS= read -r rel; do
    src="$P/$d/$rel"; dst="$CFG/$d/$rel"
    case "$rel" in conf/windowrules-*.conf|colors.conf) continue ;; esac
    mkdir -p "$(dirname "$dst")"
    [ -e "$dst" ] && { mkdir -p "$BACKUP/.config/$d/$(dirname "$rel")"; cp -a "$dst" "$BACKUP/.config/$d/$rel" 2>/dev/null; }
    if grep -q '__[A-Z]*__' "$src" 2>/dev/null; then render "$src" "$dst"; else cp -a "$src" "$dst"; fi
  done < <(cd "$P/$d" && find . -type f | sed 's|^\./||')
done
ok "hypr, waybar, rofi, swaync, wlogout, uwsm"

# reglas de ventana según la versión de Hyprland
HV=$(hypr_version); RULES=windowrules-modern.conf
[ -n "$HV" ] && { ver_ge "$HV" 0.53 || RULES=windowrules-v2.conf; }
mkdir -p "$CFG/hypr/conf"
cp "$P/hypr/conf/windowrules-modern.conf" "$CFG/hypr/conf/" 2>/dev/null
cp "$P/hypr/conf/windowrules-v2.conf"     "$CFG/hypr/conf/" 2>/dev/null
cp "$P/hypr/conf/$RULES" "$CFG/hypr/conf/windowrules.conf"
info "Hyprland ${HV:-?} → $RULES"

# gráfica
case "$GPU" in
  nvidia) cp "$P/hypr/conf/gpu-nvidia.conf"  "$CFG/hypr/conf/gpu.conf" ;;
  *)      cp "$P/hypr/conf/gpu-generic.conf" "$CFG/hypr/conf/gpu.conf" ;;
esac
# híbrida NVIDIA + integrada: hay que decirle a Hyprland cuál usar
if [ "$(gpu_list | wc -w)" -gt 1 ] && [ "$GPU" = nvidia ]; then
  warn "gráfica híbrida detectada ($(gpu_list))"
  info "si Hyprland arranca en la GPU equivocada, mira  ls -l /dev/dri/by-path/"
  info "y descomenta AQ_DRM_DEVICES en ~/.config/hypr/conf/gpu.conf"
fi
if is_laptop; then cp "$P/hypr/hypridle-laptop.conf"  "$CFG/hypr/hypridle.conf" 2>/dev/null
else               cp "$P/hypr/hypridle-desktop.conf" "$CFG/hypr/hypridle.conf" 2>/dev/null; fi
ok "gráfica: $GPU · inactividad: $(machine_kind)"
echo rofi > "$CFG/rice/menu" 2>/dev/null || true
