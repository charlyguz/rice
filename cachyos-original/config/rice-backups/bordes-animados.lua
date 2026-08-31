-- ============================================================
--  Bordes de ventana con gradiente giratorio.
--
--  IMPORTANTE: este archivo debe cargarse DESPUÉS de
--  require("noctalia").apply_theme() en hyprland.lua, porque
--  Noctalia pinta los bordes de un solo color y lo pisaría.
--
--  Instalación (con el juego CERRADO):
--    cp bordes-animados.lua ~/.config/hypr/config/
--    echo 'require("config.bordes-animados")' >> ~/.config/hypr/hyprland.lua
--
--  Para quitarlo: borra esa última línea de hyprland.lua.
-- ============================================================

-- Colores del gradiente. Estos son los de Tokyo-Night.
-- Los dos últimos dígitos son la opacidad (ff = sólido).
local c1 = "rgba(7aa2f7ff)"   -- azul
local c2 = "rgba(bb9af7ff)"   -- morado
local c3 = "rgba(7dcfffff)"   -- cian
local apagado = "rgba(1a1b26aa)"

hl.config({
    general = {
        -- Grosor del borde. 1 = fino, 5 = muy marcado.
        border_size = 3,
        col = {
            -- Tres paradas de color + ángulo inicial.
            -- Puedes usar solo dos si prefieres algo más sobrio.
            active_border = c1 .. " " .. c2 .. " " .. c3 .. " 45deg",
            inactive_border = apagado,
        },
    },
})

-- Esto es lo que hace girar el gradiente.
--   speed: más ALTO = más LENTO (es la duración del ciclo).
--          100 ≈ giro suave; 30 ≈ bastante rápido.
--   style "loop" = gira sin parar. "once" = una sola vuelta.
hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 100,
    bezier = "linear",
    style = "loop",
})
