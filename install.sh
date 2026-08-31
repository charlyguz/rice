#!/usr/bin/env bash
# ============================================================
#  install.sh — mi escritorio, en Arch o en Debian.
#
#  Sin argumentos detecta la distro y hace lo correcto:
#     Arch / CachyOS  ->  base + perfil Hyprland
#     Debian / Ubuntu ->  base + perfil Plasma (KDE)
#
#  Forzar:
#     ./install.sh --arch        Hyprland aunque estés en otra
#     ./install.sh --debian      Plasma aunque estés en otra
#     ./install.sh --terminal    SOLO shell y apps de terminal
#                                (sirve hasta en un servidor por SSH)
#
#  Otras opciones:
#     --dry-run   enseña qué haría, sin tocar nada
#     --no-apps       sin Brave / VS Code / Claude
#     --no-paquetes   solo la configuración, sin instalar nada
#     --juegos    añade Steam, Lutris, MangoHud
#     --yes       no pregunta nada
#     --sin-red   no descarga nada de internet (fuentes, cursor, plugins)
#
#  Todo lo que toca se respalda en ~/.config-backup-<fecha>.
# ============================================================
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO/lib/comun.sh"
source "$REPO/lib/paquetes.sh"
source "$REPO/lib/hardware.sh"
export REPO

CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
BIN="$HOME/.local/bin"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
export CFG DATA BIN BACKUP

PERFIL=auto; DRY=0; ASSUME_YES=0; DO_APPS=1; DO_JUEGOS=0; SOLO_TERMINAL=0; DO_PAQUETES=1
for a in "$@"; do case "$a" in
  --arch|--hyprland) PERFIL=hyprland ;;
  --debian|--plasma) PERFIL=plasma ;;
  --terminal)        SOLO_TERMINAL=1 ;;
  --dry-run)         DRY=1 ;;
  --no-apps)         DO_APPS=0 ;;
  --no-paquetes)     DO_PAQUETES=0 ;;
  --juegos)          DO_JUEGOS=1 ;;
  --yes|-y)          ASSUME_YES=1 ;;
  --sin-red)         RICE_SIN_RED=1; export RICE_SIN_RED ;;
  --help|-h)         sed -n '2,26p' "$0"; exit 0 ;;
  *) die "opción desconocida: $a" ;;
esac; done
export DRY ASSUME_YES DO_APPS DO_JUEGOS

backup_path() {
  local p="$1"
  [ -e "$p" ] || [ -L "$p" ] || return 0
  local rel="${p#"$HOME"/}"
  run mkdir -p "$BACKUP/$(dirname "$rel")"
  run cp -a "$p" "$BACKUP/$rel" 2>/dev/null || true
}
export -f backup_path 2>/dev/null || true

# ------------------------------------------------------------
step "Reconociendo el sistema"
detect_distro
GPU=$(gpu_vendor); KIND=$(machine_kind)
info "distro:   $DISTRO_NAME"
info "familia:  $FAMILY"
info "máquina:  $KIND"
info "gráfica:  $(gpu_list)"
[ "$(id -u)" = 0 ] && [ -z "${RICE_ALLOW_ROOT:-}" ] && die "no lo corras como root."

if [ "$PERFIL" = auto ]; then
  case "$FAMILY" in
    arch)   PERFIL=hyprland ;;
    debian) PERFIL=plasma ;;
    fedora) PERFIL=plasma ;;
    *)      PERFIL=ninguno ;;
  esac
fi
[ "$SOLO_TERMINAL" = 1 ] && PERFIL=ninguno
case "$PERFIL" in
  hyprland) ok "perfil: Hyprland  (el de tu CachyOS, sin Noctalia)" ;;
  plasma)   ok "perfil: KDE Plasma  (lo mismo, traducido)" ;;
  ninguno)  ok "perfil: solo terminal (no se toca el escritorio)" ;;
esac
export PERFIL GPU KIND

# ------------------------------------------------------------
step "Comprobaciones"
if ! sudo -n true 2>/dev/null && ! sudo -v 2>/dev/null; then
  if ! id -nG "$USER" 2>/dev/null | tr ' ' '\n' | grep -qx sudo && ! id -nG "$USER" | tr ' ' '\n' | grep -qx wheel; then
    err "Tu usuario ($USER) no puede usar sudo."
    echo; echo "    En Debian:  su -c 'usermod -aG sudo $USER'"
    echo "    En Arch:    su -c 'usermod -aG wheel $USER'"
    echo; echo "    Luego cierra sesión, entra otra vez y repite."
    exit 1
  fi
  die "sudo no me deja continuar."
fi
ok "sudo disponible"

if [ "$FAMILY" = debian ] && [ "$DISTRO_ID" = debian ] && [ "$DRY" = 0 ]; then
  if ! grep -rqs 'non-free-firmware' /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
    if ask "Faltan contrib/non-free-firmware (drivers, códecs). ¿Los activo?" y; then
      for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/*.list; do
        [ -f "$f" ] || continue
        case "$f" in
          *.sources) sudo sed -i '/^Components:/{/contrib/!s/$/ contrib non-free non-free-firmware/}' "$f" ;;
          *)         sudo sed -i '/^deb /{/contrib/!s/$/ contrib non-free non-free-firmware/}' "$f" ;;
        esac
      done
      ok "contrib + non-free activados"
    fi
  else info "contrib/non-free ya activos"; fi
fi

# ------------------------------------------------------------
if [ "$DO_PAQUETES" = 1 ]; then
step "Paquetes"
pkg_refresh
[ "$FAMILY" = arch ] && ensure_aur >/dev/null 2>&1
instalar_lista() { local n="$1"; shift; info "— $n"; pkg_install "$@"; }
mapfile -t T < <(pkgs_terminal);   instalar_lista "terminal y shell" "${T[@]}"
mapfile -t F < <(pkgs_fuentes);    instalar_lista "fuentes" "${F[@]}"
mapfile -t M < <(pkgs_multimedia); instalar_lista "multimedia" "${M[@]}"
mapfile -t S < <(pkgs_sistema);    instalar_lista "sistema, red e impresión" "${S[@]}"
mapfile -t D < <(pkgs_desarrollo); instalar_lista "desarrollo" "${D[@]}"
if [ "$DO_JUEGOS" = 1 ]; then mapfile -t J < <(pkgs_juegos); instalar_lista "juegos" "${J[@]}"; fi

if [ "$FAMILY" = debian ]; then
  info "— lo que Debian no empaqueta:"
  while IFS='|' read -r n c; do [ -n "$n" ] && info "    · $n → $c"; done < <(terminal_faltantes_debian)
fi
else
  step "Paquetes"; info "saltados (--no-paquetes)"
fi
export DO_PAQUETES

# ------------------------------------------------------------
bash "$REPO/base/instalar.sh" || warn "la parte base terminó con avisos"

# ------------------------------------------------------------
case "$PERFIL" in
  hyprland) [ -x "$REPO/perfiles/hyprland/instalar.sh" ] && bash "$REPO/perfiles/hyprland/instalar.sh" ;;
  plasma)   [ -x "$REPO/perfiles/plasma/instalar.sh"   ] && bash "$REPO/perfiles/plasma/instalar.sh" ;;
esac

# ------------------------------------------------------------
step "Resumen"
[ -d "$BACKUP" ] && info "respaldo: $BACKUP"
if [ "${#MISSING[@]}" -gt 0 ]; then
  warn "no se instaló (no existe aquí o falló):"
  printf '      · %s\n' "${MISSING[@]}" | sort -u
fi
echo
printf '%s  Listo.%s Cierra sesión y vuelve a entrar.\n' "$C_B$C_G" "$C_R"
printf '  Después:  %srice-doctor%s revisa · %srice-help%s los atajos · %srice-theme menu%s el tema\n' \
  "$C_B" "$C_R" "$C_B" "$C_R" "$C_B" "$C_R"
