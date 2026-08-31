# shellcheck shell=bash
# ============================================================
#  Detección de hardware. Todo sale de /sys, sin depender de
#  lspci ni de nada que pueda no estar instalado.
# ============================================================

# Devuelve: nvidia, amd, intel o generic. Si hay híbrida (portátil con
# Optimus) manda NVIDIA, porque es la que necesita variables especiales.
# Se puede forzar con  RICE_GPU=nvidia ./install.sh  si la detección falla.
gpu_vendor() {
  [ -n "${RICE_GPU:-}" ] && { echo "$RICE_GPU"; return; }
  local vendors="" v
  for f in /sys/class/drm/card[0-9]*/device/vendor; do
    [ -r "$f" ] || continue
    v=$(cat "$f" 2>/dev/null)
    case "$v" in
      0x10de) vendors="$vendors nvidia" ;;
      0x1002|0x1022) vendors="$vendors amd" ;;
      0x8086) vendors="$vendors intel" ;;
    esac
  done
  case " $vendors " in
    *nvidia*) echo nvidia ;;
    *amd*)    echo amd ;;
    *intel*)  echo intel ;;
    *)        echo generic ;;
  esac
}

gpu_list() { # descripción legible de todas las GPU
  [ -n "${RICE_GPU:-}" ] && { echo "${RICE_GPU} (forzada)"; return; }
  local out="" f v
  for f in /sys/class/drm/card[0-9]*/device/vendor; do
    [ -r "$f" ] || continue
    v=$(cat "$f" 2>/dev/null)
    case "$v" in
      0x10de) out="$out NVIDIA" ;;
      0x1002|0x1022) out="$out AMD" ;;
      0x8086) out="$out Intel" ;;
      *) out="$out $v" ;;
    esac
  done
  echo "${out# }" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

nvidia_driver_ok() { [ -n "${RICE_FAKE_NVIDIA_OK:-}" ] && return 0; [ -d /sys/module/nvidia ] || [ -e /dev/nvidia0 ]; }

# Forzables:  RICE_BATTERY=1|0   RICE_BACKLIGHT=1|0
has_battery() {
  case "${RICE_BATTERY:-}" in 1) return 0 ;; 0) return 1 ;; esac
  case "${RICE_MACHINE:-}" in escritorio|desktop) return 1 ;; esac
  ls /sys/class/power_supply/BAT* >/dev/null 2>&1
}
has_backlight() {
  case "${RICE_BACKLIGHT:-}" in 1) return 0 ;; 0) return 1 ;; esac
  case "${RICE_MACHINE:-}" in escritorio|desktop) return 1 ;; esac
  ls /sys/class/backlight/*/brightness >/dev/null 2>&1
}

# laptop / desktop según el chasis DMI, con la batería como desempate
# Forzable con  RICE_MACHINE=laptop  o  RICE_MACHINE=escritorio
is_laptop() {
  case "${RICE_MACHINE:-}" in laptop) return 0 ;; escritorio|desktop) return 1 ;; esac
  local t=""
  [ -r /sys/class/dmi/id/chassis_type ] && t=$(cat /sys/class/dmi/id/chassis_type)
  case "$t" in
    8|9|10|11|12|14|30|31|32) return 0 ;;
    3|4|5|6|7|13|15|16|17|23|24) return 1 ;;
  esac
  has_battery
}

machine_kind() { is_laptop && echo laptop || echo escritorio; }

# Salidas de video conectadas: DP-1, HDMI-A-1, eDP-1...
connected_outputs() {
  local d n
  for d in /sys/class/drm/card[0-9]*-*; do
    [ -r "$d/status" ] || continue
    [ "$(cat "$d/status")" = connected ] || continue
    n="${d##*/}"; n="${n#card[0-9]-}"; n="${n#card[0-9][0-9]-}"
    echo "$n"
  done
}

cpu_vendor() {
  if grep -qi 'AuthenticAMD' /proc/cpuinfo 2>/dev/null; then echo amd
  elif grep -qi 'GenuineIntel' /proc/cpuinfo 2>/dev/null; then echo intel
  else echo generic; fi
}
