// ============================================================
//  Panel de Plasma — la traducción de tu barra de Waybar.
//
//  Se aplica con:
//    gdbus call --session --dest org.kde.plasmashell \
//      --object-path /PlasmaShell \
//      --method org.kde.PlasmaShell.evaluateScript "$(cat panel.js)"
//
//  Distribución, igual que la tenías:
//    IZQUIERDA  lanzador · CPU · RAM · reloj
//    CENTRO     escritorios + ventanas abiertas
//    DERECHA    bandeja del sistema + botón de sesión
//
//  Cada widget va en try/catch a propósito: si un applet no está
//  instalado, se salta y el panel se construye igual. Un panel a
//  medias es molesto; ningún panel es un problema serio.
// ============================================================

function add(panel, id, configure) {
    try {
        var w = panel.addWidget(id);
        if (configure && w) { configure(w); }
        return w;
    } catch (e) {
        print("rice: no se pudo añadir " + id + " (" + e + ")");
        return null;
    }
}

// Fuera los paneles que hubiera. install.sh respalda la config antes.
var old = panels();
for (var i = 0; i < old.length; i++) { old[i].remove(); }

var p = new Panel;
p.location = "top";
p.height = Math.round(44 * (screenGeometry(0).height > 1440 ? 1.2 : 1));
p.alignment = "center";

// "fit" hace que el panel mida lo que miden sus widgets en vez de ocupar
// todo el ancho: es lo que lo convierte en una isla flotante y no en una
// barra pegada de lado a lado.
try { p.lengthMode = "fit"; } catch (e) { p.lengthMode = "fill"; }

// Flotante: se despega de los bordes. Es lo que más cambia el aspecto.
try { p.floating = true; } catch (e) { print("rice: esta versión no tiene paneles flotantes"); }

// Fondo translúcido siempre (2 = translúcido, 1 = opaco, 0 = adaptativo).
// El tema Rice ya dibuja el fondo con transparencia; esto evita que Plasma
// le meta un respaldo sólido detrás cuando maximizas una ventana.
try {
    p.currentConfigGroup = ["General"];
    p.writeConfig("panelOpacity", 2);
    p.writeConfig("floatingness", 1);
    p.reloadConfig();
} catch (e) { print("rice: no pude fijar la opacidad del panel (" + e + ")"); }

// ---------------- IZQUIERDA ----------------
add(p, "org.kde.plasma.kickoff", function (w) {
    w.currentConfigGroup = ["General"];
    w.writeConfig("icon", "start-here-kde-symbolic");
    w.writeConfig("favoritesPortedToKAstats", true);
    w.writeConfig("primaryActions", 0);
});

// CPU y RAM. Vienen de plasma-systemmonitor; si falta, se saltan solos.
add(p, "org.kde.plasma.systemmonitor", function (w) {
    w.currentConfigGroup = ["Appearance"];
    w.writeConfig("chartFace", "org.kde.ksysguard.textonly");
    w.writeConfig("title", "CPU");
    w.currentConfigGroup = ["Sensors"];
    w.writeConfig("highPrioritySensorIds", '["cpu/all/usage"]');
    w.writeConfig("totalSensors", '["cpu/all/usage"]');
});
add(p, "org.kde.plasma.systemmonitor", function (w) {
    w.currentConfigGroup = ["Appearance"];
    w.writeConfig("chartFace", "org.kde.ksysguard.textonly");
    w.writeConfig("title", "RAM");
    w.currentConfigGroup = ["Sensors"];
    w.writeConfig("highPrioritySensorIds", '["memory/physical/usedPercent"]');
    w.writeConfig("totalSensors", '["memory/physical/usedPercent"]');
});

add(p, "org.kde.plasma.digitalclock", function (w) {
    w.currentConfigGroup = ["Appearance"];
    w.writeConfig("showDate", true);
    w.writeConfig("dateFormat", "custom");
    w.writeConfig("customDateFormat", "ddd d MMM");
    w.writeConfig("use24hFormat", 2);
    w.writeConfig("fontWeight", 700);
});

// ---------------- CENTRO ----------------
add(p, "org.kde.plasma.panelspacer", function (w) {
    w.currentConfigGroup = ["General"];
    w.writeConfig("expanding", true);
});

add(p, "org.kde.plasma.pager", function (w) {
    w.currentConfigGroup = ["General"];
    w.writeConfig("displayedText", 0);       // solo el número
    w.writeConfig("showWindowIcons", false);
    w.writeConfig("wrapPage", true);
});

add(p, "org.kde.plasma.icontasks", function (w) {
    w.currentConfigGroup = ["General"];
    w.writeConfig("launchers", [
        "applications:kitty.desktop",
        "applications:brave-browser.desktop",
        "applications:org.kde.dolphin.desktop",
        "applications:code.desktop"
    ].join(","));
    w.writeConfig("groupingStrategy", 1);
    w.writeConfig("showOnlyCurrentDesktop", false);
    w.writeConfig("iconSpacing", 1);
});

add(p, "org.kde.plasma.panelspacer", function (w) {
    w.currentConfigGroup = ["General"];
    w.writeConfig("expanding", true);
});

// ---------------- DERECHA ----------------
// La bandeja ya trae volumen, red, portapapeles, notificaciones,
// bluetooth y batería. Por eso el lado derecho es mucho más simple
// que en Waybar: no hay que cablear cada cosa a mano.
add(p, "org.kde.plasma.systemtray", function (w) {
    w.currentConfigGroup = ["General"];
    w.writeConfig("scaleIconsToFit", false);
});

add(p, "org.kde.plasma.lock_logout", function (w) {
    w.currentConfigGroup = ["General"];
    w.writeConfig("show_requestShutDown", true);
    w.writeConfig("show_lockScreen", true);
    w.writeConfig("show_logout", true);
    w.writeConfig("show_switchUser", false);
    w.writeConfig("show_suspend", false);
    w.writeConfig("show_hibernate", false);
});

print("rice: panel construido");
