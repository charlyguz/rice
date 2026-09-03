#!/usr/bin/env bash
# ============================================================
#  Ajustes de Plasma. Todo con kwriteconfig6, que es la forma
#  soportada de tocar la config de KDE: idempotente y reversible.
#  Nada de reescribir archivos a mano.
#
#  Lo llama install.sh, pero puedes correrlo suelto para reaplicar.
# ============================================================
set -uo pipefail
have() { command -v "$1" >/dev/null 2>&1; }
KW=""
for c in kwriteconfig6 kwriteconfig5; do have "$c" && { KW="$c"; break; }; done
[ -n "$KW" ] || { echo "no encuentro kwriteconfig6 — ¿seguro que esto es Plasma?" >&2; exit 1; }
kw() { "$KW" "$@"; }

UI_FONT="${RICE_UI_FONT:-Outfit}"
MONO_FONT="${RICE_MONO_FONT:-JetBrainsMono Nerd Font}"
ICONS="${RICE_ICONS:-Papirus-Dark}"
CURSOR="${RICE_CURSOR:-Bibata-Modern-Ice}"
f()  { echo "$1,$2,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"; }
fb() { echo "$1,$2,-1,5,700,0,0,0,0,0,0,0,0,0,0,1"; }

echo "· fuentes, iconos y cursor"
kw --file kdeglobals --group General --key font                  "$(f "$UI_FONT" 10)"
kw --file kdeglobals --group General --key fixed                 "$(f "$MONO_FONT" 10)"
kw --file kdeglobals --group General --key menuFont              "$(f "$UI_FONT" 10)"
kw --file kdeglobals --group General --key smallestReadableFont  "$(f "$UI_FONT" 8)"
kw --file kdeglobals --group General --key toolBarFont           "$(f "$UI_FONT" 10)"
kw --file kdeglobals --group WM      --key activeFont            "$(fb "$UI_FONT" 10)"
kw --file kdeglobals --group General --key XftAntialias true
kw --file kdeglobals --group General --key XftHintStyle hintslight
kw --file kdeglobals --group General --key XftSubPixel rgb
kw --file kdeglobals --group Icons   --key Theme "$ICONS"
kw --file kcminputrc  --group Mouse  --key cursorTheme "$CURSOR"
kw --file kcminputrc  --group Mouse  --key cursorSize 24

echo "· comportamiento general"
kw --file kdeglobals --group KDE --key SingleClick false
kw --file kdeglobals --group KDE --key widgetStyle Breeze
# 0.5 = animaciones al doble de rápido. Se siente ágil sin parecer roto.
kw --file kdeglobals --group KDE --key AnimationDurationFactor 0.5
kw --file kdeglobals --group General --key TerminalApplication kitty
kw --file kdeglobals --group General --key TerminalService kitty.desktop
kw --file kdeglobals --group General --key BrowserApplication brave-browser.desktop
# no restaurar las apps de la sesión anterior al arrancar
kw --file ksmserverrc --group General --key loginMode emptySession

echo "· ventanas: bordes, sombras, botones"
kw --file kwinrc --group org.kde.kdecoration2 --key library org.kde.breeze
kw --file kwinrc --group org.kde.kdecoration2 --key theme Breeze
kw --file kwinrc --group org.kde.kdecoration2 --key BorderSize None
kw --file kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false
kw --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
kw --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight IAX
kw --file breezerc --group Common --key OutlineCloseButton true
kw --file breezerc --group Common --key ShadowSize ShadowLarge
kw --file breezerc --group Common --key ShadowStrength 180
kw --file breezerc --group Windeco --key DrawBackgroundGradient false
kw --file breezerc --group Windeco --key DrawBorderOnMaximizedWindows false
kw --file breezerc --group Windeco --key DrawTitleBarSeparator false

echo "· efectos: blur y ventanas inactivas translúcidas"
kw --file kwinrc --group Compositing --key Enabled true
kw --file kwinrc --group Compositing --key LatencyPolicy Low
kw --file kwinrc --group Compositing --key WindowsBlockCompositing true
kw --file kwinrc --group Plugins --key blurEnabled true
kw --file kwinrc --group Plugins --key contrastEnabled true
kw --file kwinrc --group Plugins --key kwin4_effect_translucencyEnabled true
kw --file kwinrc --group Plugins --key wobblywindowsEnabled false
kw --file kwinrc --group Plugins --key kwin4_effect_dimscreenEnabled false
kw --file kwinrc --group Plugins --key slideEnabled true
kw --file kwinrc --group Plugins --key kwin4_effect_fadeEnabled true
kw --file kwinrc --group Effect-blur --key BlurStrength 8
kw --file kwinrc --group Effect-blur --key NoiseStrength 3
# 85 % = exactamente la opacidad que tenías para las ventanas sin foco
kw --file kwinrc --group Effect-kwin4_effect_translucency --key Inactive 85
kw --file kwinrc --group Effect-kwin4_effect_translucency --key MoveResize 90
kw --file kwinrc --group Effect-kwin4_effect_translucency --key Dialogs 100
kw --file kwinrc --group Effect-kwin4_effect_translucency --key Menus 100
kw --file kwinrc --group Effect-kwin4_effect_translucency --key Inactive_Exclude "kitty,konsole,brave-browser,firefox,mpv,vlc,code,steam"

echo "· alt-tab y bordes de pantalla"
kw --file kwinrc --group TabBox --key LayoutName thumbnail_grid
kw --file kwinrc --group TabBox --key HighlightWindows true
kw --file kwinrc --group Windows --key BorderlessMaximizedWindows false
kw --file kwinrc --group Windows --key Placement Centered
kw --file kwinrc --group Windows --key FocusPolicy ClickToFocus
kw --file kwinrc --group Windows --key DelayFocusInterval 0
# esquina superior izquierda = vista general (como el SUPER de siempre)
kw --file kwinrc --group Effect-overview --key BorderActivate 9

echo "· escritorios virtuales (los 'workspaces' que tenías)"
kw --file kwinrc --group Desktops --key Number 4
kw --file kwinrc --group Desktops --key Rows 1
i=1
for n in Principal Web Código Juegos; do
  kw --file kwinrc --group Desktops --key "Id_$i" "rice-desktop-$i"
  kw --file kwinrc --group Desktops --key "Name_$i" "$n"
  i=$((i+1))
done

echo "· portapapeles (Klipper)"
kw --file klipperrc --group General --key MaxClipItems 60
kw --file klipperrc --group General --key KeepClipboardContents true
kw --file klipperrc --group General --key PreventEmptyClipboard true
kw --file klipperrc --group General --key IgnoreImages false
# SyncClipboards=false a propósito. En X11 hay DOS portapapeles: el de
# Ctrl+C (CLIPBOARD) y el de seleccionar con el ratón (PRIMARY). Con esto en
# true, Klipper los fusiona y CUALQUIER texto que subrayes machaca lo que
# tenías copiado: imposible seleccionar algo para sustituirlo.
kw --file klipperrc --group General --key SyncClipboards false
# Y que las selecciones del ratón tampoco ensucien el historial.
kw --file klipperrc --group General --key IgnoreSelection true

echo "· capturas (Spectacle)"
mkdir -p "$HOME/Pictures/Screenshots"
kw --file spectaclerc --group General --key autoSaveImage true
kw --file spectaclerc --group General --key clipboardGroup PostScreenshotCopyImage
kw --file spectaclerc --group Save --key defaultSaveLocation "file://$HOME/Pictures/Screenshots/"
kw --file spectaclerc --group Save --key saveFilenameFormat "captura-<yyyy>-<MM>-<dd>_<HH><mm><ss>"

echo "· Dolphin"
kw --file dolphinrc --group General --key ShowFullPath true
kw --file dolphinrc --group General --key BrowseThroughArchives true
kw --file dolphinrc --group General --key ShowSelectionToggle false
kw --file dolphinrc --group General --key RememberOpenedTabs false
kw --file dolphinrc --group "KFileDialog Settings" --key "Show hidden files" false
kw --file dolphinrc --group DetailsMode --key PreviewSize 22
kw --file dolphinrc --group MainWindow --key MenuBar Disabled

echo "· bloqueo de pantalla"
kw --file kscreenlockerrc --group Daemon --key Timeout 10
kw --file kscreenlockerrc --group Daemon --key LockGrace 5
kw --file kscreenlockerrc --group Daemon --key Autolock true

echo "· luz nocturna"
kw --file kwinrc --group NightColor --key Active true
kw --file kwinrc --group NightColor --key Mode Times
kw --file kwinrc --group NightColor --key NightTemperature 4500
kw --file kwinrc --group NightColor --key EveningBeginFixed 2100
kw --file kwinrc --group NightColor --key MorningBeginFixed 0700

echo "· ahorro de energía: que una PC no se suspenda sola"
if [ ! -d /sys/class/power_supply/BAT0 ] && [ ! -d /sys/class/power_supply/BAT1 ]; then
  kw --file powermanagementprofilesrc --group AC --group SuspendSession --key idleTime 0
  kw --file powermanagementprofilesrc --group AC --group SuspendSession --key suspendType 0
  kw --file powermanagementprofilesrc --group AC --group DPMSControl --key idleTime 900
  echo "  (escritorio: apaga pantallas a los 15 min, no suspende)"
fi
