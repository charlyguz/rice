# shellcheck shell=bash
# ============================================================
#  Utilidades compartidas: detección de distro, log, paquetes.
# ============================================================

# --- colores de salida ---
if [ -t 1 ]; then
  C_R=$'\033[0m'; C_B=$'\033[1m'; C_G=$'\033[32m'; C_Y=$'\033[33m'; C_C=$'\033[36m'; C_E=$'\033[31m'; C_D=$'\033[2m'
else C_R=; C_B=; C_G=; C_Y=; C_C=; C_E=; C_D=; fi

step() { printf '\n%s▸ %s%s\n' "$C_B$C_C" "$*" "$C_R"; }
ok()   { printf '  %s✓%s %s\n' "$C_G" "$C_R" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_Y" "$C_R" "$*"; }
err()  { printf '  %s✗%s %s\n' "$C_E" "$C_R" "$*"; }
info() { printf '  %s%s%s\n' "$C_D" "$*" "$C_R"; }
die()  { err "$*"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

ask() { # ask "pregunta" [y|n]  -> 0 si sí
  local q="$1" def="${2:-y}" a
  [ "${ASSUME_YES:-0}" = 1 ] && return 0
  local hint="[S/n]"; [ "$def" = n ] && hint="[s/N]"
  read -r -p "  $q $hint " a </dev/tty || a=""
  a="${a:-$def}"
  case "${a,,}" in s|si|sí|y|yes) return 0 ;; *) return 1 ;; esac
}

run() { # respeta --dry-run
  if [ "${DRY:-0}" = 1 ]; then info "(dry-run) $*"; return 0; fi
  "$@"
}

# ------------------------------------------------------------
#  Detección de distro
# ------------------------------------------------------------
detect_distro() {
  DISTRO_ID=unknown; DISTRO_NAME="desconocida"; FAMILY=unknown; CODENAME=""; DISTRO_VER=""
  local osr="${RICE_OS_RELEASE:-/etc/os-release}"
  if [ -r "$osr" ]; then
    # shellcheck disable=SC1090
    . "$osr"
    DISTRO_ID="${ID:-unknown}"
    DISTRO_NAME="${PRETTY_NAME:-$DISTRO_ID}"
    CODENAME="${VERSION_CODENAME:-}"
    DISTRO_VER="${VERSION_ID:-}"
    local like="${ID_LIKE:-}"
    case " $DISTRO_ID $like " in
      *" arch "*|*cachyos*|*endeavouros*|*manjaro*) FAMILY=arch ;;
      *" debian "*|*" ubuntu "*)                    FAMILY=debian ;;
      *" fedora "*|*" rhel "*|*centos*)             FAMILY=fedora ;;
      *" suse "*|*opensuse*)                        FAMILY=suse ;;
    esac
    [ "$FAMILY" = unknown ] && case "$DISTRO_ID" in
      arch|cachyos|endeavouros|manjaro|garuda|artix) FAMILY=arch ;;
      debian|ubuntu|pop|linuxmint|zorin|elementary)  FAMILY=debian ;;
      fedora|nobara|rhel|centos|almalinux|rocky)     FAMILY=fedora ;;
      opensuse*|sles)                                FAMILY=suse ;;
    esac
  fi
  export DISTRO_ID DISTRO_NAME FAMILY CODENAME DISTRO_VER
}

# ------------------------------------------------------------
#  Instalación de paquetes, tolerante a fallos
#  Si un paquete no existe en esta distro, lo apunta en MISSING
#  y sigue. Nunca aborta la instalación entera por uno.
# ------------------------------------------------------------
MISSING=()

pkg_refresh() {
  case "$FAMILY" in
    arch)   run sudo pacman -Sy --noconfirm >/dev/null ;;
    debian) run sudo apt-get update -qq ;;
    fedora) : ;;
    suse)   run sudo zypper -q refresh ;;
  esac
}

_pkg_install_one() {
  case "$FAMILY" in
    arch)   sudo pacman -S --needed --noconfirm "$1" ;;
    debian) sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$1" ;;
    fedora) sudo dnf install -y -q "$1" ;;
    suse)   sudo zypper -q -n install "$1" ;;
    *) return 1 ;;
  esac
}

pkg_installed() {
  case "$FAMILY" in
    arch)   pacman -Qi "$1" >/dev/null 2>&1 ;;
    debian) dpkg -s "$1" >/dev/null 2>&1 ;;
    fedora) rpm -q "$1" >/dev/null 2>&1 ;;
    suse)   rpm -q "$1" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

pkg_install() { # pkg_install pkg1 pkg2 ...
  local p
  for p in "$@"; do
    [ -z "$p" ] && continue
    if pkg_installed "$p"; then info "ya estaba: $p"; continue; fi
    if [ "${DRY:-0}" = 1 ]; then info "(dry-run) instalar $p"; continue; fi
    if _pkg_install_one "$p" >/dev/null 2>&1; then ok "$p"
    else warn "no disponible aquí: $p"; MISSING+=("$p"); fi
  done
}

# ------------------------------------------------------------
#  AUR (solo Arch): asegura un helper
# ------------------------------------------------------------
AUR_HELPER=""
ensure_aur() {
  [ "$FAMILY" = arch ] || return 1
  for h in paru yay pikaur; do have "$h" && { AUR_HELPER="$h"; return 0; }; done
  warn "no hay ayudante de AUR (paru/yay)"
  ask "¿Instalo 'yay' desde el AUR? (necesita compilar, ~1 min)" y || return 1
  run sudo pacman -S --needed --noconfirm base-devel git
  local t; t=$(mktemp -d)
  ( cd "$t" && git clone -q https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm )
  rm -rf "$t"
  have yay && { AUR_HELPER=yay; return 0; }
  return 1
}

aur_install() {
  [ -n "$AUR_HELPER" ] || { MISSING+=("$@"); return 1; }
  local p
  for p in "$@"; do
    if [ "${DRY:-0}" = 1 ]; then info "(dry-run) AUR: $p"; continue; fi
    if "$AUR_HELPER" -S --needed --noconfirm "$p" >/dev/null 2>&1; then ok "$p (AUR)"
    else warn "falló en AUR: $p"; MISSING+=("$p"); fi
  done
}

# ------------------------------------------------------------
#  Descargas auxiliares
# ------------------------------------------------------------
dl() { # dl <url> <destino>
  [ "${RICE_SIN_RED:-0}" = 1 ] && return 1
  if   have curl; then curl -fsSL --connect-timeout 10 --max-time 300 "$1" -o "$2"
  elif have wget; then wget -q --timeout=10 --tries=2 -O "$2" "$1"
  else return 1; fi
}

# git clone que no se queda colgado si no hay red
gclone() { # gclone <url> <destino>
  [ "${RICE_SIN_RED:-0}" = 1 ] && return 1
  have git || return 1
  timeout 180 git clone --depth=1 "$1" "$2" >/dev/null 2>&1
}

gh_latest_asset() { # gh_latest_asset <owner/repo> <patrón grep>
  # La API de GitHub limita a 60 peticiones/hora por IP, así que primero
  # se resuelve sin ella:
  #   1) /releases/latest redirige a la etiqueta -> sacamos la versión
  #   2) /releases/expanded_assets/<tag> sí lista los enlaces de descarga
  #   3) si algo de eso falla, entonces sí, la API
  local repo="$1" pat="$2" tag url
  tag=$(_fetch_effective_url "https://github.com/$repo/releases/latest")
  tag="${tag##*/tag/}"
  if [ -n "$tag" ] && [ "$tag" != "https://github.com/$repo/releases/latest" ]; then
    url=$(_fetch "https://github.com/$repo/releases/expanded_assets/$tag" \
          | grep -o "/$repo/releases/download/[^\"']*" | grep -m1 -- "$pat")
    [ -n "$url" ] && { echo "https://github.com$url"; return 0; }
  fi
  _fetch "https://api.github.com/repos/$repo/releases/latest" \
    | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 | grep -m1 -- "$pat"
}

_fetch() {
  if   have curl; then curl -fsSL "$1" 2>/dev/null
  elif have wget; then wget -qO- "$1" 2>/dev/null
  fi
}

_fetch_effective_url() {
  if   have curl; then curl -fsSL -o /dev/null -w '%{url_effective}' "$1" 2>/dev/null
  elif have wget; then wget -q -S --spider "$1" 2>&1 | awk '/^  Location: /{u=$2} END{print u}'
  fi
}

# ------------------------------------------------------------
#  Debian: instalar desde una suite concreta (backports)
# ------------------------------------------------------------
pkg_install_suite() { # pkg_install_suite <suite> pkg...
  local suite="$1"; shift
  local p
  for p in "$@"; do
    [ -z "$p" ] && continue
    if pkg_installed "$p"; then info "ya estaba: $p"; continue; fi
    if [ "${DRY:-0}" = 1 ]; then info "(dry-run) instalar $p desde $suite"; continue; fi
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq -t "$suite" "$p" >/dev/null 2>&1; then
      ok "$p  ($suite)"
    else
      warn "no disponible en $suite: $p"; MISSING+=("$p")
    fi
  done
}

# ------------------------------------------------------------
#  Versión de Hyprland SIN necesitar una sesión corriendo.
#  (hyprctl solo responde dentro de una sesión, así que primero
#   se lo preguntamos al gestor de paquetes.)
# ------------------------------------------------------------
hypr_version() {
  local v=""
  case "$FAMILY" in
    arch)   v=$(pacman -Q hyprland 2>/dev/null | awk '{print $2}') ;;
    debian) v=$(dpkg-query -W -f='${Version}' hyprland 2>/dev/null) ;;
    fedora|suse) v=$(rpm -q --qf '%{VERSION}' hyprland 2>/dev/null) ;;
  esac
  # limpia epoch y sufijos de empaquetado: 0.55.2+ds-1~bpo13+1 -> 0.55.2
  v="${v#*:}"; v="${v%%[-+~]*}"
  if [ -z "$v" ]; then v=$(hyprctl version 2>/dev/null | grep -om1 '[0-9]\+\.[0-9]\+\.\?[0-9]*'); fi
  if [ -z "$v" ]; then
    for b in Hyprland hyprland; do
      have "$b" && v=$("$b" --version 2>/dev/null | grep -om1 '[0-9]\+\.[0-9]\+\.\?[0-9]*') && break
    done
  fi
  echo "$v"
}

# ¿La versión $1 es >= $2?  (compara x.y.z)
ver_ge() {
  local a b
  IFS=. read -r a b _ <<<"${1:-0.0.0}"
  local ma mb; IFS=. read -r ma mb _ <<<"${2:-0.0.0}"
  a=${a:-0}; b=${b:-0}; ma=${ma:-0}; mb=${mb:-0}
  [ "$a" -gt "$ma" ] && return 0
  [ "$a" -lt "$ma" ] && return 1
  [ "$b" -ge "$mb" ]
}

# Tema GTK que existe de verdad en esta máquina
gtk_theme_name() {
  local d
  for d in "$HOME/.local/share/themes" /usr/share/themes; do
    [ -d "$d/adw-gtk3-dark" ] && { echo adw-gtk3-dark; return; }
  done
  for d in "$HOME/.local/share/themes" /usr/share/themes; do
    [ -d "$d/adw-gtk3" ] && { echo adw-gtk3; return; }
  done
  for d in "$HOME/.local/share/themes" /usr/share/themes; do
    [ -d "$d/Adwaita-dark" ] && { echo Adwaita-dark; return; }
  done
  echo Adwaita
}
