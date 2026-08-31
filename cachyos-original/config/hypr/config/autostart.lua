-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    -- Barra estilo HyDE. Config en ~/.config/waybar/
    -- (el 'command -v' evita errores si Waybar no está instalado)
    hl.exec_cmd("sh -c 'command -v waybar >/dev/null && waybar'")
    hl.exec_cmd("xhost +SI:localuser:root")
end)
