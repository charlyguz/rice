#!/usr/bin/env bash
# ============================================================
#  Atajos de teclado. Los mismos que tenías en Hyprland,
#  traducidos a KDE.
#
#  Dos mecanismos distintos, porque KDE los separa:
#   · acciones de KWin/Plasma  -> grupos [kwin], [plasmashell]...
#   · lanzar un programa       -> un .desktop + [services][...]
# ============================================================
set -uo pipefail
have() { command -v "$1" >/dev/null 2>&1; }
KW=""; for c in kwriteconfig6 kwriteconfig5; do have "$c" && { KW="$c"; break; }; done
[ -n "$KW" ] || { echo "no encuentro kwriteconfig6" >&2; exit 1; }
APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$APPS"

# sc <grupo> <acción> <atajo> [nombre visible]
sc() { "$KW" --file kglobalshortcutsrc --group "$1" --key "$2" "$3,none,${4:-$2}"; }

# launcher <id> <nombre> <comando> <icono> <atajo>
launcher() {
  cat > "$APPS/rice-$1.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$2
Exec=$3
Icon=$4
NoDisplay=true
Terminal=false
X-KDE-GlobalAccel-CommandShortcut=true
EOF
  "$KW" --file kglobalshortcutsrc --group services --group "rice-$1.desktop" --key _launch "$5,none,$2"
}

echo "· lanzar aplicaciones"
launcher terminal   "Terminal"        "kitty"                       "utilities-terminal"     "Meta+Return"
launcher terminal2  "Terminal (T)"    "kitty"                       "utilities-terminal"     "Meta+T"
launcher archivos   "Archivos"        "dolphin"                     "system-file-manager"    "Meta+E"
launcher navegador  "Navegador"       "brave-browser"               "internet-web-browser"   "Meta+W"
launcher editor     "Editor"          "code"                        "text-editor"            "Meta+N"
launcher calc       "Calculadora"     "kcalc"                       "accessories-calculator" "Meta+C"
launcher monitor    "Monitor"         "kitty -e btop"               "utilities-system-monitor" "Ctrl+Shift+Escape"
launcher tema       "Cambiar tema"    "$HOME/.local/bin/rice-theme menu"      "preferences-desktop-theme" "Meta+Z"
launcher fondo      "Cambiar fondo"   "$HOME/.local/bin/rice-wallpaper menu"  "preferences-desktop-wallpaper" "Meta+Shift+W"

echo "· ventanas"
sc kwin "Window Close"              "Meta+Q"        "Cerrar ventana"
sc kwin "Window Maximize"           "Meta+D"        "Maximizar"
sc kwin "Window Fullscreen"         "Meta+F"        "Pantalla completa"
sc kwin "Window Minimize"           "Meta+H"        "Minimizar"
sc kwin "Window Above Other Windows" "Meta+Shift+A" "Mantener encima"
sc kwin "Switch Window Left"        "Meta+Left"     "Foco a la izquierda"
sc kwin "Switch Window Right"       "Meta+Right"    "Foco a la derecha"
sc kwin "Switch Window Up"          "Meta+Up"       "Foco arriba"
sc kwin "Switch Window Down"        "Meta+Down"     "Foco abajo"
sc kwin "Window Quick Tile Left"    "Meta+Shift+Left"   "Encajar a la izquierda"
sc kwin "Window Quick Tile Right"   "Meta+Shift+Right"  "Encajar a la derecha"
sc kwin "Window Quick Tile Top"     "Meta+Shift+Up"     "Encajar arriba"
sc kwin "Window Quick Tile Bottom"  "Meta+Shift+Down"   "Encajar abajo"

echo "· escritorios"
for i in 1 2 3 4; do
  sc kwin "Switch to Desktop $i"     "Meta+$i"        "Ir al escritorio $i"
  sc kwin "Window to Desktop $i"     "Meta+Shift+$i"  "Llevar al escritorio $i"
done
sc kwin "Switch One Desktop to the Left"  "Meta+Ctrl+Left"  "Escritorio anterior"
sc kwin "Switch One Desktop to the Right" "Meta+Ctrl+Right" "Escritorio siguiente"
sc kwin "Overview"                        "Meta+Tab"        "Vista general"
sc kwin "Grid View"                       "Meta+G"          "Rejilla de ventanas"

echo "· sistema"
sc ksmserver  "Lock Session"  "Meta+L"        "Bloquear"
sc ksmserver  "Log Out"       "Meta+Alt+C"    "Cerrar sesión"
sc plasmashell "activate widget 0" "" ""      2>/dev/null || true
# KRunner con Meta+Space (el lanzador de "escribe y corre")
sc krunner    "_launch"       "Meta+Space"    "KRunner"
sc org.kde.krunner.desktop "_launch" "Meta+Space" "KRunner"
# Portapapeles: mismo Meta+V de siempre.
# OJO: en Plasma 6 Klipper se fusionó dentro de plasmashell, así que sus
# atajos viven en [plasmashell] y NO en [klipper]. Escribo los dos grupos
# porque en Plasma 5 era al revés y así funciona en ambos.
sc plasmashell "show-on-mouse-pos"  "Meta+V"       "Portapapeles"
sc plasmashell "clipboard_action"   "Meta+Ctrl+X"  "Acciones del portapapeles"
sc plasmashell "cycleNextAction"    "Meta+Ctrl+V"  "Siguiente del portapapeles"
sc plasmashell "edit_clipboard"     "Meta+Alt+V"   "Editar portapapeles"
sc klipper "show-on-mouse-pos" "Meta+V"       "Portapapeles"
sc klipper "clipboard_action"  "Meta+Ctrl+X"  "Acciones del portapapeles"
# Notificaciones
sc plasmashell "toggle do not disturb" "Meta+Shift+N" "No molestar"

echo "· capturas (como las tenías: Print = región)"
sc org.kde.spectacle.desktop "RectangularRegionScreenShot" "Print"        "Captura de región"
sc org.kde.spectacle.desktop "FullScreenScreenShot"        "Meta+Print"   "Captura completa"
sc org.kde.spectacle.desktop "ActiveWindowScreenShot"      "Meta+Shift+Print" "Captura de la ventana"
sc org.kde.spectacle.desktop "RecordRegion"                "Meta+Shift+R" "Grabar región"

echo "· volumen y medios (por si el teclado tiene teclas dedicadas)"
sc kmix "increase_volume" "Volume Up"   "Subir volumen"
sc kmix "decrease_volume" "Volume Down" "Bajar volumen"
sc kmix "mute"            "Volume Mute" "Silenciar"
sc plasmashell "increase_volume" "Volume Up"   "Subir volumen"
sc plasmashell "decrease_volume" "Volume Down" "Bajar volumen"
sc plasmashell "mute"            "Volume Mute" "Silenciar"

echo
echo "Los atajos se leen al iniciar sesión. Para probarlos ahora:"
echo "    kquitapp6 plasmashell && kstart plasmashell"
echo "  o simplemente cierra sesión y vuelve a entrar."
