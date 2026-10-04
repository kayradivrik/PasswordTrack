import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    width: 960
    height: 600
    visible: true
    
    readonly property real uiScale: 1.0
    readonly property real currentScaledWidth: width / uiScale
    readonly property int dashboardWidth: currentScaledWidth - Math.max(40, currentScaledWidth - 1100)
    readonly property int tableAvailableWidth: Math.max(10, dashboardWidth - 32 - 176)
    readonly property int colServiceWidth: Math.max(100, Math.floor(tableAvailableWidth * 0.28))
    readonly property int colUsernameWidth: Math.max(120, Math.floor(tableAvailableWidth * 0.38))
    readonly property int colPasswordWidth: Math.max(100, tableAvailableWidth - colServiceWidth - colUsernameWidth)
    
    Item {
        anchors.fill: parent
        
        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: Math.max(20, (parent.width - 1100) / 2)
            anchors.rightMargin: Math.max(20, (parent.width - 1100) / 2)
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: 'red'
                
                Text { text: 'Dashboard Width: ' + dashboardWidth + ' | Layout Width: ' + parent.width; anchors.centerIn: parent }
            }
            
            RowLayout {
                Layout.fillWidth: true
                Rectangle { color: 'blue'; Layout.preferredWidth: colServiceWidth; Layout.fillHeight: true }
                Rectangle { color: 'green'; Layout.preferredWidth: colUsernameWidth; Layout.fillHeight: true }
                Rectangle { color: 'yellow'; Layout.preferredWidth: colPasswordWidth; Layout.fillHeight: true }
                Rectangle { color: 'purple'; Layout.preferredWidth: 176; Layout.fillHeight: true }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
