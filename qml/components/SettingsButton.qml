import QtQuick
import QtQuick.Controls

// Ayarlar ekranı için ortak, tutarlı stilde buton.
// 'highlighted: true' verilirse dolgulu (vurgulu) görünür.
Button {
    id: control

    implicitHeight: 36
    leftPadding: 18
    rightPadding: 18
    font.pixelSize: 12
    font.bold: true
    palette.buttonText: highlighted ? bgMain : textMain
    opacity: enabled ? 1.0 : 0.5

    background: Rectangle {
        radius: 8
        color: control.highlighted
               ? (control.down ? "#cccccc" : (control.hovered ? accentHover : accent))
               : (control.down ? "#2a2a2a" : (control.hovered ? "#262626" : "#181818"))
        border.width: 1
        border.color: control.highlighted ? accent : (control.hovered ? "#4a4a4a" : borderMain)

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }
}
