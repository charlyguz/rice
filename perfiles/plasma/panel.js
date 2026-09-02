// ============================================================
//  Panel de Plasma — barra abajo, iconos centrados.
//
//    IZQUIERDA  menú · escritorios (como NÚMEROS)
//    CENTRO     ventanas abiertas y anclados
//    DERECHA    bandeja · reloj con fecha · mostrar escritorio
//
//  El diseño anterior (isla flotante arriba, estilo Waybar) está
//  en panel-isla-arriba.js.bak. Se cambió porque en Plasma esa
//  isla depende de un tema de escritorio propio, y el del repo
//  no se renderizaba bien (salían franjas donde el SVG fallaba).
//
//  Se aplica con:
//    gdbus call --session --dest org.kde.plasmashell \
//      --object-path /PlasmaShell \
//      --method org.kde.PlasmaShell.evaluateScript "$(cat panel.js)"
// ============================================================

function add(p, id, cfg) {
  try { var w = p.addWidget(id); if (cfg && w) cfg(w); return w; }
  catch (e) { print("rice: no se pudo añadir " + id + " (" + e + ")"); return null; }
}

// Hueco expandible: es lo que empuja los iconos al centro.
function spacer(p) {
  add(p, "org.kde.plasma.panelspacer", function (w) {
    w.currentConfigGroup = ["General"];
    w.writeConfig("expanding", true);
  });
}

var old = panels();
for (var i = 0; i < old.length; i++) old[i].remove();

var p = new Panel;
p.location = "bottom";
p.height = Math.round(44 * (screenGeometry(0).height > 1440 ? 1.25 : 1));
p.alignment = "center";
p.lengthMode = "fill";
try { p.floating = false; } catch (e) {}

// ---------------- izquierda ----------------
add(p, "org.kde.plasma.kickoff", function (w) {
  w.currentConfigGroup = ["General"];
  w.writeConfig("icon", "start-here-kde");
  w.writeConfig("favoritesPortedToKAstats", true);
  w.writeConfig("primaryActions", 0);
});

add(p, "org.kde.plasma.pager", function (w) {
  w.currentConfigGroup = ["General"];
  // displayedText es un enum: 0=Number, 1=Name, 2=None.
  // 0 => los escritorios salen como 1 2 3 4.
  w.writeConfig("displayedText", 0);
  w.writeConfig("showWindowIcons", false);
  w.writeConfig("wrapPage", true);
});

// ---------------- centro ----------------
spacer(p);

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
  w.writeConfig("maxStripes", 1);
  w.writeConfig("iconSpacing", 2);
  w.writeConfig("indicateAudioStreams", true);
});

spacer(p);

// ---------------- derecha ----------------
add(p, "org.kde.plasma.systemtray", function (w) {
  w.currentConfigGroup = ["General"];
  w.writeConfig("scaleIconsToFit", false);
});

add(p, "org.kde.plasma.digitalclock", function (w) {
  w.currentConfigGroup = ["Appearance"];
  w.writeConfig("showDate", true);
  w.writeConfig("dateFormat", "custom");
  w.writeConfig("customDateFormat", "dd/MM/yyyy");
  w.writeConfig("use24hFormat", 0);
});

add(p, "org.kde.plasma.showdesktop");

// ---------------- reloj grande en el escritorio ----------------
// Plasma no deja fijar la geometría por script (el containment manda),
// así que sale con tamaño por defecto: se arrastra y se estira a mano.
try {
  var d = desktops()[0];
  var yaHay = false;
  var dw = d.widgets();
  for (var k = 0; k < dw.length; k++) {
    if (dw[k].type === "org.rice.relojgrande") yaHay = true;
  }
  if (!yaHay) {
    var c = d.addWidget("org.rice.relojgrande");
    
  }
} catch (e) { print("rice: no pude poner el reloj del escritorio (" + e + ")"); }

print("rice: panel abajo con iconos centrados y escritorios en numeros");
