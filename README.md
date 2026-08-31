# rice — mi escritorio, en Arch o en Debian

Mi configuración real, sacada de CachyOS archivo por archivo, y traducida
para que funcione igual en las dos distros que uso.

```bash
git clone https://github.com/TUUSUARIO/rice ~/rice
cd ~/rice
./install.sh
```

Detecta la distro sola:

| Estoy en | Instala |
|---|---|
| Arch / CachyOS / EndeavourOS | base + **Hyprland** (mi setup de siempre, sin Noctalia) |
| Debian / Ubuntu | base + **KDE Plasma** (lo mismo, traducido) |
| Un servidor por SSH | `./install.sh --terminal` — solo shell y herramientas |

Forzar: `./install.sh --arch` · `./install.sh --debian` · `./install.sh --terminal`

---

## Por qué un solo repo y no dos

Porque **como el 60% no depende del escritorio**: zsh con Powerlevel10k, kitty,
micro, btop, starship, yazi, ripgrep, zoxide, las fuentes, el cursor, la paleta
de color, los wallpapers, el `.gitconfig`. Eso es idéntico en Arch y en Debian.
Con dos scripts, ese 60% estaría duplicado y en tres meses uno tendría un
arreglo que el otro no.

```
install.sh          detecta y despacha
base/               lo que es igual en las dos
perfiles/
  hyprland/         Arch: Hyprland + Waybar + rofi
  plasma/           Debian: KDE con todo traducido
temas/              las paletas y el motor de color
cachyos-original/   mi config de CachyOS tal cual, como archivo histórico
```

---

## El shell (zsh)

Es la traducción de `/usr/share/cachyos-zsh-config` para que no dependa de
CachyOS. Mismo oh-my-zsh con los mismos plugins (`git fzf extract`), mismo
Powerlevel10k, mismas sugerencias y resaltado, mismo historial.

**Mi `.p10k.zsh` va verbatim, las 1840 líneas.** No es una reconstrucción: es el
archivo que salió de `p10k configure`.

Los alias que dependían de pacman están traducidos:

| CachyOS | Debian |
|---|---|
| `update` → `pacman -Syu` | `apt update && apt upgrade` |
| `rmpkg` → `pacman -Rsn` | `apt remove --purge` |
| `cleanup` → quitar huérfanos | `apt autoremove --purge` |
| `cleanch` → limpiar caché | `apt clean && autoclean` |
| `fixpacman` → borrar db.lck | `fixapt` → borrar los locks de apt |
| `rip` → últimos instalados | lee `/var/log/dpkg.log` |
| `apt` = `man pacman` (la broma) | **no se toca** — en Debian apt es real |

Los que no dependen del gestor (`make -j$(nproc)`, `c`, `please`, `tb`, `jctl`,
`n`) van igual en las dos.

Mis añadidos van en `~/.zshrc.local`, que no lo pisa ninguna reinstalación.

---

## Apps de terminal

Todas las que tenía, con su configuración:

**micro** (con el tema catppuccin-macchiato y sus colorschemes) · **btop** con
mis ajustes exactos: procesos ordenados por memoria, cajas `proc mem net cpu`,
refresco 2 s · **starship** · **kitty** con opacidad 0.6, padding 25 y
cursor_trail · **alacritty** · **fastfetch** · **yazi**, **ripgrep**,
**zoxide**, **duf**, **glances**, **eza**, **bat**, **fzf**, **gh**.

En Debian faltan cuatro empaquetados y el instalador los resuelve por su cuenta:
`yazi` (binario de GitHub), `starship` (script oficial), `oh-my-zsh` y
`zsh-history-substring-search` (clon de git).

---

## Los atajos

Los mismos en las dos, con la tecla Super. En Hyprland salen de
`conf/binds.conf`; en Plasma se escriben en KWin y en `kglobalshortcutsrc`.

| Tecla | Qué hace |
|---|---|
| `Super+Return` / `Super+T` | Terminal (kitty) |
| `Super+E` | Archivos (Dolphin) |
| `Super+W` | Navegador |
| `Super+N` | Editor |
| `Super+C` | Calculadora |
| `Super+Space` | Lanzador (rofi en Arch · KRunner en KDE) |
| `Super+Q` | Cerrar ventana |
| `Super+F` / `Super+D` | Pantalla completa / maximizar |
| `Super+flechas` | Mover el foco |
| `Super+Shift+flechas` | Mover / encajar la ventana |
| `Super+1..4` | Workspaces / escritorios |
| `Super+Shift+1..4` | Llevar la ventana ahí |
| `Super+Tab` | Cambiar de ventana / vista general |
| **`Print`** | **Captura de región** |
| `Super+Print` | Captura completa |
| **`Super+V`** | **Portapapeles** |
| `Super+L` | Bloquear |
| `Super+Z` | Cambiar de paleta |
| `Super+Shift+W` | Cambiar de fondo |
| `Ctrl+Shift+Esc` | btop |

---

## El color

Una paleta de 25 líneas y `rice-theme` la escribe en todo lo que la entiende:

Plasma (`.colors` nativo + color de acento) · Hyprland (`colors.conf`) ·
Waybar · GTK3 y GTK4 · kitty · Konsole · alacritty · btop · micro · starship ·
fzf.

```
rice-theme menu          elegir paleta
rice-theme toggle        claro <-> oscuro
rice-theme tokyonight    la que uso
```

Seis incluidas: `tokyonight` (la mía, hex por hex de la que generaba Noctalia),
`tokyonight-day`, `catppuccin-mocha`, `catppuccin-latte`, `rose-pine`,
`gruvbox-dark`.

---

## Los paquetes

`lib/paquetes.sh` es el mapa Arch↔Debian de mis 219 paquetes explícitos,
por categorías: terminal, fuentes, multimedia, sistema/red/impresión,
desarrollo, juegos (opcional con `--juegos`), y el escritorio de cada perfil.

Fuera quedó lo que cualquier distro instala sola (base, kernel, firmware) y lo
que solo existe en Arch y no tiene sentido portar (`paru`, `pacman-contrib`,
`reflector`, `mkinitcpio`, `debtap`, los `cachyos-*`).

Si un paquete no existe en la distro, se apunta y se sigue. Al final el
instalador lista lo que faltó.

---

## Comandos

```
rice-doctor       revisión: qué está puesto, qué falta, qué lo suple
rice-help         los atajos y las rutas
rice-theme        el color
rice-wallpaper    los fondos
rice-panel        (KDE) rehacer / restaurar / resetear el panel
```

---

## Notas

**NVIDIA.** La laptop es híbrida: RTX 4050 + Radeon 680M. Tanto Hyprland como la
sesión Wayland de Plasma necesitan `nvidia_drm.modeset=1`; el instalador lo
comprueba y lo arregla. Si Hyprland arranca en la GPU equivocada, hay que
descomentar `AQ_DRM_DEVICES` en `conf/gpu.conf` — el instalador avisa cuando
detecta las dos tarjetas.

**Debian.** Todo el stack de Hyprland vive en `trixie-backports` y hay que
instalarlo con `apt install -t trixie-backports`; sin el `-t`, apt lo ignora.
Y si instalé Debian con contraseña de root, mi usuario no está en el grupo
`sudo` — el instalador lo detecta y da el comando exacto.

**Carpetas en español.** `Escritorio`, `Descargas`, `Documentos`, `Imágenes`…
Se replican en Debian, porque si no, media configuración apunta a rutas que no
existen.

**`cachyos-original/`** guarda mi CachyOS tal cual: los `.lua` de Hyprland, el
Waybar completo, el `kdeglobals` que generaba Noctalia, los temas de terminal,
la lista de paquetes y hasta los nueve respaldos de `rice-backups` de cuando
peleaba con los bordes animados. No lo usa nadie; está por si algún día quiero
comparar.

**Lo que no se puede traducir.** En Plasma no existe el borde LED animado de las
islas de Waybar, ni los gaps de un tiling WM. El panel de Plasma se acerca con un
tema propio (translúcido, redondeado, flotante), pero no es lo mismo. Está dicho
en claro para no llevarme la sorpresa después.
