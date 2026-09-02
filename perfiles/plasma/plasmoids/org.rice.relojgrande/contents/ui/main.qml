/*
 * Reloj grande — el día de la semana manda, debajo fecha y hora.
 *
 * El reloj que trae Plasma pone SIEMPRE la hora en grande y no deja
 * invertirlo, por eso este widget existe.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property date ahora: new Date()
    // Sin fondo: el widget flota sobre el fondo de pantalla.
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.ahora = new Date()
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        id: caja
        Layout.minimumWidth:  420
        Layout.minimumHeight: 170
        implicitWidth:  680
        implicitHeight: 230

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Math.round(caja.height * 0.03)

            // ---- el día, en grande ----
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(root.ahora, "dddd").toUpperCase()
                color: Kirigami.Theme.textColor
                font.family: Kirigami.Theme.defaultFont.family
                font.weight: Font.Light
                font.pixelSize: Math.round(caja.height * 0.42)
                font.letterSpacing: Math.round(caja.height * 0.045)
                renderType: Text.NativeRendering
            }

            // ---- la fecha ----
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(root.ahora, "d MMM yyyy").toUpperCase()
                color: Kirigami.Theme.textColor
                opacity: 0.85
                font.family: Kirigami.Theme.defaultFont.family
                font.weight: Font.Normal
                font.pixelSize: Math.round(caja.height * 0.115)
                font.letterSpacing: Math.round(caja.height * 0.02)
                renderType: Text.NativeRendering
            }

            // ---- la hora, entre guiones ----
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "— " + Qt.formatTime(root.ahora, "h:mm AP") + " —"
                color: Kirigami.Theme.textColor
                opacity: 0.7
                font.family: Kirigami.Theme.defaultFont.family
                font.weight: Font.Normal
                font.pixelSize: Math.round(caja.height * 0.10)
                font.letterSpacing: Math.round(caja.height * 0.018)
                renderType: Text.NativeRendering
            }
        }
    }
}
