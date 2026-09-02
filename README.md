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
lib/                distro, hardware y el mapa de paquetes
base/               lo que es igual en las dos
  zsh/              .zshrc, p10k, alias y el autocompletado
  kitty/ rofi/      terminal y lanzador
  tmux/ btop/ micro/ fastfetch/ alacritty/ git/
  grub/             tema Fallout del arranque
bin/                rice-doctor, rice-fetch, rice-notas, rice-shortcuts...
perfiles/
  hyprland/         Arch: Hyprland + Waybar + rofi
  plasma/           Debian: KDE con todo traducido
temas/              las paletas y el motor de color
assets/             fuentes, logo y las imágenes del terminal
wallpapers/         los fondos
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

**micro** (tema catppuccin-macchiato) · **btop** con mis ajustes exactos:
procesos por memoria, cajas `proc mem net cpu`, refresco 2 s · **starship** ·
**kitty** con transparencia, padding y `cursor_trail` · **alacritty** ·
**fastfetch** · **yazi**, **ripgrep**, **zoxide**, **duf**, **glances**,
**eza**, **fzf**, **gh**.

Y las que se añadieron después, que son las que más se notan a diario:

| | |
|---|---|
| **bat** | `cat` con sintaxis. Además es el paginador de las manpages y de `--help` |
| **delta** | Diffs de git legibles. Configurado como pager en el `.gitconfig` |
| **tldr** | Ejemplos de un comando en 10 líneas en vez de una manpage de 400 |
| **lazygit** | Git entero en una TUI (`lg`) |
| **atuin** | Sustituye `Ctrl+R`: historial buscable, y sincroniza entre máquinas |
| **tmux** | Multiplexor. Por SSH cierras la conexión y la sesión sigue viva |
| **dust · procs · ncdu** | Disco y procesos, en color y navegables |
| **rofi** | El lanzador (`Meta+Space`), con tema Tokyo Night propio |

**Ojo con Debian:** aquí `bat` se instala como `batcat` y `fd` como `fdfind`,
porque los nombres cortos ya estaban cogidos. `aliases-herramientas.zsh`
devuelve los nombres de siempre, pero en un script usa el real.

Lo que Debian no empaqueta y el instalador resuelve solo: `yazi` (binario de
GitHub), `starship` (script oficial), `oh-my-zsh`, `zsh-history-substring-search`,
`fzf-tab` y `zsh-completions` (clones de git).

---

## El autocompletado

Tab no abre una lista: abre un buscador. Es **fzf-tab** sobre el completado de
zsh, más 191 definiciones extra de **zsh-completions**.

- Busca **sin distinguir mayúsculas** y **por trozos**: `cn/co/pl` encuentra
  `config/corp/plugins`.
- **Tolera dos erratas** antes de rendirse.
- **Vista previa** mientras te mueves: `eza` si es carpeta, `bat` si es fichero,
  el valor si es una variable, el proceso si es un `kill`.

Arranca en ~0.12 s porque `compinit` cachea y solo revisa el volcado una vez al día.

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
| `Super+Space` | **Lanzador (rofi)**, en Arch y en KDE |
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
| **`Super+Shift+B`** | **Notas rápidas en .txt** |
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
rice-fetch        el saludo del terminal (imagen o ASCII, decide solo)
rice-notas        bloc de notas en .txt          (Meta+Shift+B)
rice-panel        (KDE) rehacer / restaurar / resetear el panel
rice-shortcuts    (KDE) reasignar los atajos por D-Bus
```

---

## El saludo del terminal

`rice-fetch` mira si el terminal sabe dibujar imágenes y actúa en consecuencia:

- **En kitty**: saca **una imagen al azar** de `~/Imágenes/terminal-imgs`.
- **En una TTY pelada o por SSH**: el logo grande en ASCII a color.

Así la misma orden vale en el escritorio y en un servidor. Se puede forzar con
`rice-fetch --ascii` o `rice-fetch --imagen`.

Las imágenes van en `assets/terminal-imgs/` y el instalador las copia con `cp -n`,
así que **nunca pisa las tuyas**. Pon las que quieras en esa carpeta.

---

## El reloj del escritorio

Un plasmoide propio, `org.rice.relojgrande`: el **día de la semana en grande**,
debajo la fecha y la hora entre guiones.

Existe porque el reloj que trae Plasma pone **siempre** la hora como elemento
grande y no hay opción para invertirlo. Son 80 líneas de QML, así que no hay que
descargar nada de ninguna tienda. Vive en `perfiles/plasma/plasmoids/` y el
instalador lo copia a `~/.local/share/plasma/plasmoids/`.

Para moverlo o cambiarle el tamaño: clic derecho en el escritorio → *Entrar en
modo edición*, y se arrastra. Plasma **ignora la geometría cuando se asigna por
script** (la controla el contenedor), así que la posición inicial se escribe
directamente en `ItemGeometries` del `appletsrc`.

---

## La barra

Abajo, a lo ancho, con los iconos **centrados**: dos espaciadores expandibles a
los lados de `icontasks` los empujan al medio, y dejan menú y escritorios
pegados a la izquierda, bandeja y reloj a la derecha.

Los escritorios salen como **números**: `displayedText` del pager es un enum
(`0=Number`, `1=Name`, `2=None`), y va en `0`.

El diseño anterior —isla flotante arriba, estilo Waybar— está guardado en
`perfiles/plasma/panel-isla-arriba.js.bak`. Se cambió porque en Plasma esa isla
depende de un tema de escritorio propio, y el del repo no se renderizaba: Plasma
pintaba encima su patrón de "elemento no encontrado".

---

## Arranque (GRUB)

Tema **Fallout** en el menú de arranque, de
[shvchk/fallout-grub-theme](https://github.com/shvchk/fallout-grub-theme) (MIT).

Se instala a mano y no con su `install.sh`, porque aquel vuelve a descargar el
tarball y pide el idioma por un menú interactivo que sin terminal se cuelga.
Solo se toca si existe `/boot/grub` y no estás en modo `--terminal`, y se
respalda `/etc/default/grub` antes.

En Debian hay que desactivar `/etc/grub.d/05_debian_theme`: ejecuta su propio
`background_image` **después** del `set theme` y se come el fondo del tema.
Para revertirlo: `sudo chmod +x /etc/grub.d/05_debian_theme && sudo update-grub`.

---

## Notas

**NVIDIA.** Tanto Hyprland como la sesión Wayland de Plasma necesitan
`nvidia_drm.modeset=1`; el instalador lo comprueba y lo arregla. En Debian ese
parámetro es `0400 root:root`, así que un usuario normal lee `?` **aunque esté
activo**: por eso se mira también `/proc/cmdline` y `/etc/modprobe.d/`. Sin esa
comprobación, el instalador rehace el initramfs y pide un reinicio sin motivo.

**Debian.** El stack de Hyprland vive en `trixie-backports` y hay que instalarlo
con `apt install -t trixie-backports`; sin el `-t`, apt lo ignora. Y si instalaste
Debian con contraseña de root, tu usuario no está en el grupo `sudo` — el
instalador lo detecta y da el comando exacto.

**Nombres de paquete que cambian en Debian.** `kdeplasma-addons` se llama
`plasma-widgets-addons`; `tldr` es un paquete virtual sin candidato y el bueno es
`tealdeer`; `bat` y `fd` instalan los binarios como `batcat` y `fdfind`.

**Atajos en KDE.** Escribir `kglobalshortcutsrc` con `kwriteconfig6` **no basta**:
KDE mantiene su registro en memoria y reescribe el fichero al salir, y además
rechaza en silencio las teclas que ya tiene otro, dejando la entrada vacía. Por
eso existe `rice-shortcuts`, que los asigna por D-Bus liberando antes al ocupante.

Tres colisiones de fábrica que hay que liberar: `Meta+T` (editor de mosaico de
KWin), `Meta+Q` (selector de actividades) y `Meta+D` (vistazo al escritorio).

**El portapapeles.** En Plasma 6, Klipper vive **dentro de plasmashell**. El
componente `klipper` sigue en `kglobalshortcutsrc` pero ya no lo respalda ningún
proceso: si le asignas `Meta+V`, kglobalaccel la acepta y **nunca la captura**.
Tiene que ir a `plasmashell`.

**KRunner en Wayland con NVIDIA** no dibuja su ventana: falla con
`eglSwapBuffers ... 0x300d` (EGL_BAD_SURFACE) y se queda en 1x1 píxeles. El
proceso vive y responde a D-Bus, así que parece que el atajo "no hace nada".
Por eso el lanzador es **rofi**, que además arranca mucho más rápido.

**Las imágenes del terminal, dos trampas.** fastfetch trae `imagemagick7` y
`chafa` compilados pero los carga con `dlopen` buscando `libMagickCore-7.Q16.so`
**sin número de versión**: Debian solo instala el `.so.10`, y el symlink sin
versión lo trae el paquete `-dev`. Sin eso fallan *todos* los modos de imagen en
silencio. Y la segunda: fastfetch se niega a pintar imágenes si su salida no va a
un terminal directo (*"Image logo is not supported in pipe mode"*), así que el
saludo tiene que ir **antes** del preámbulo del instant prompt de p10k, que
captura la salida en un buffer. Ahí arriba `~/.local/bin` aún no está en el PATH,
por eso se llama con la ruta explícita.

**Carpetas en español.** `Escritorio`, `Descargas`, `Documentos`, `Imágenes`…
Se replican en Debian, porque si no, media configuración apunta a rutas que no
existen. Los scripts miran la carpeta en español y caen a la inglesa si no está.

**`cachyos-original/`** guarda mi CachyOS tal cual: los `.lua` de Hyprland, el
Waybar completo, el `kdeglobals` que generaba Noctalia, los temas de terminal y
la lista de paquetes. No lo usa nadie; está por si algún día quiero comparar.

**Lo que no se puede traducir.** En Plasma no existe el borde LED animado de las
islas de Waybar, ni los gaps de un tiling WM. Está dicho en claro para no
llevarme la sorpresa después.

---

## Si lo usas tú

El instalador **te pregunta tu nombre y tu correo** para git la primera vez: el
repo no lleva ningún `[user]`, para que no acabes firmando commits con el correo
de otro.

Todo lo que toca se respalda en `~/.config-backup-<fecha>` antes de cambiarlo, y
`rice-doctor` te dice qué quedó puesto y qué falta.

Las imágenes de `assets/terminal-imgs/` son mías; cambia esa carpeta por las
tuyas y `rice-fetch` las usará igual.
