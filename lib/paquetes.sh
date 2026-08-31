# shellcheck shell=bash
# ============================================================
#  Mapa de paquetes Arch <-> Debian.
#
#  Sale de tu `pacman -Qe` real en CachyOS (219 paquetes), filtrado:
#  fuera lo que cualquier distro instala sola (base, kernel, firmware,
#  utilidades de disco que vienen de serie) y fuera lo que es
#  exclusivo de Arch y no tiene sentido portar (paru, pacman-contrib,
#  reflector, mkinitcpio, debtap, los cachyos-*).
#
#  Cada categoría devuelve la lista de la distro activa. Si un paquete
#  no existe, pkg_install lo apunta y sigue: nada aborta por uno.
# ============================================================

# ---------------- TERMINAL: shell y herramientas ----------------
pkgs_terminal() {
  case "$FAMILY" in
  arch) cat <<'P'
zsh
oh-my-zsh-git
zsh-theme-powerlevel10k
zsh-syntax-highlighting
zsh-autosuggestions
zsh-history-substring-search
kitty
alacritty
micro
nano
nano-syntax-highlighting
vim
btop
glances
fastfetch
yazi
ripgrep
fd
zoxide
duf
eza
bat
fzf
pv
plocate
less
bash-completion
github-cli
meld
rsync
wget
curl
git
unzip
unrar
p7zip
jq
man-db
man-pages
pkgfile
expac
pacman-contrib
starship
P
  ;;
  debian) cat <<'P'
zsh
zsh-theme-powerlevel10k
zsh-syntax-highlighting
zsh-autosuggestions
kitty
alacritty
micro
nano
vim
btop
glances
fastfetch
ripgrep
fd-find
zoxide
duf
eza
bat
fzf
pv
plocate
less
bash-completion
gh
meld
rsync
wget
curl
git
unzip
unrar-free
p7zip-full
jq
man-db
manpages
command-not-found
P
  ;;
  esac
}
# En Debian no están empaquetados; se resuelven aparte
terminal_faltantes_debian() { cat <<'P'
yazi|se baja el binario de GitHub (releases)
starship|se instala con su script oficial
oh-my-zsh|lo clona install.sh en ~/.local/share/oh-my-zsh
zsh-history-substring-search|lo clona install.sh
nano-syntax-highlighting|Debian ya trae resaltado en nano
P
}

# ---------------- FUENTES ----------------
pkgs_fuentes() {
  case "$FAMILY" in
  arch) cat <<'P'
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
ttf-dejavu
ttf-liberation
ttf-opensans
cantarell-fonts
gsfonts
ttf-meslo-nerd
awesome-terminal-fonts
P
  ;;
  debian) cat <<'P'
fonts-noto-core
fonts-noto-cjk
fonts-noto-color-emoji
fonts-dejavu
fonts-liberation
fonts-open-sans
fonts-cantarell
gsfonts
fonts-font-awesome
fontconfig
P
  ;;
  esac
}

# ---------------- MULTIMEDIA Y AUDIO ----------------
pkgs_multimedia() {
  case "$FAMILY" in
  arch) cat <<'P'
pipewire-alsa
pipewire-pulse
wireplumber
alsa-utils
alsa-plugins
sof-firmware
pavucontrol
vlc
mpv
gst-libav
gst-plugins-bad
gst-plugins-ugly
gst-plugin-va
gst-plugin-pipewire
ffmpegthumbnailer
P
  ;;
  debian) cat <<'P'
pipewire-audio
pipewire-alsa
pipewire-pulse
wireplumber
alsa-utils
firmware-sof-signed
pavucontrol
vlc
mpv
gstreamer1.0-libav
gstreamer1.0-plugins-bad
gstreamer1.0-plugins-ugly
gstreamer1.0-vaapi
gstreamer1.0-pipewire
ffmpegthumbnailer
P
  ;;
  esac
}

# ---------------- RED, BLUETOOTH, IMPRESIÓN ----------------
pkgs_sistema() {
  case "$FAMILY" in
  arch) cat <<'P'
networkmanager
networkmanager-openvpn
bluez
bluez-utils
bluez-obex
iwd
modemmanager
openssh
wpa_supplicant
ufw
bind
nfs-utils
cups
cups-filters
cups-pdf
hplip
gutenprint
system-config-printer
ghostscript
smartmontools
hdparm
usbutils
dmidecode
hwinfo
ethtool
upower
power-profiles-daemon
flatpak
xdg-user-dirs
btrfs-progs
snapper
exfatprogs
dosfstools
P
  ;;
  debian) cat <<'P'
network-manager
network-manager-openvpn
network-manager-gnome
bluez
bluez-obexd
iwd
modemmanager
openssh-client
wpasupplicant
ufw
bind9-dnsutils
nfs-common
cups
cups-filters
printer-driver-cups-pdf
hplip
printer-driver-gutenprint
system-config-printer
ghostscript
smartmontools
hdparm
usbutils
dmidecode
hwinfo
ethtool
upower
power-profiles-daemon
flatpak
xdg-user-dirs
btrfs-progs
snapper
exfatprogs
dosfstools
P
  ;;
  esac
}

# ---------------- DESARROLLO ----------------
pkgs_desarrollo() {
  case "$FAMILY" in
  arch) cat <<'P'
base-devel
cmake
ninja
python
python-pyqt5
python-reportlab
python-defusedxml
python-packaging
jdk17-openjdk
nodejs
npm
P
  ;;
  debian) cat <<'P'
build-essential
cmake
ninja-build
python3
python3-pip
python3-venv
python3-pyqt5
python3-reportlab
python3-defusedxml
python3-packaging
openjdk-17-jdk
nodejs
npm
P
  ;;
  esac
}

# ---------------- JUEGOS (opcional) ----------------
pkgs_juegos() {
  case "$FAMILY" in
  arch)   printf 'steam\nlutris\ngamemode\nmangohud\nwine\nwine-gecko\nwine-mono\n' ;;
  debian) printf 'steam-installer\nlutris\ngamemode\nmangohud\nwine\nwine64\n' ;;
  esac
}

# ---------------- ESCRITORIO: Hyprland (perfil Arch) ----------------
pkgs_hyprland() { cat <<'P'
hyprland
hyprlock
hypridle
hyprpaper
hyprpicker
hyprpolkitagent
xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk
uwsm
waybar
rofi-wayland
cliphist
wl-clipboard
grim
slurp
satty
swww
swaync
wlogout
swayosd
playerctl
brightnessctl
qt6ct
qt5ct
nwg-look
adw-gtk-theme
papirus-icon-theme
dolphin
sddm
P
}

# ---------------- ESCRITORIO: Plasma (perfil Debian) ----------------
pkgs_plasma() { cat <<'P'
plasma-systemmonitor
kdeplasma-addons
kde-config-gtk-style
breeze-gtk-theme
plasma-browser-integration
kde-spectacle
plasma-nm
plasma-pa
powerdevil
bluedevil
ark
gwenview
okular
kcalc
dolphin
dolphin-plugins
konsole
papirus-icon-theme
qt6ct
qt6-wayland
gnome-themes-extra
sddm
P
}
plasma_base() { printf 'kde-plasma-desktop\nplasma-workspace-wayland\n'; }
plasma_backports() { cat <<'P'
P
}

# ---------------- APPS QUE NO VIENEN DE LOS REPOS ----------------
# Cada una con su vía oficial. install.sh las trata una por una.
apps_externas() { cat <<'P'
brave|Brave|repo oficial de Brave (script dl.brave.com)
code|Visual Studio Code|repo oficial de Microsoft
claude-desktop|Claude Desktop|repo apt de Anthropic (solo Debian/Ubuntu)
librewolf|LibreWolf|repo oficial de LibreWolf
android-studio|Android Studio|descarga de developer.android.com
P
}
