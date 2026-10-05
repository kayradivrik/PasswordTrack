import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: historyDialog
    x: (parent.width - width * scale) / 2
    y: (parent.height - height * scale) / 2
    width: Math.min(500, parent.width / uiScale - 40)
    scale: Math.min(1.2, Math.max(0.85, uiScale))
    transformOrigin: Item.Center
    parent: Overlay.overlay
    modal: true

    property int entryId: 0
    property string serviceName: ""
    property var historyList: []

    function openForEntry(id, service) {
        entryId = id
        serviceName = service
        historyList = vaultManager.getPasswordHistory(id)
        open()
    }

    background: Rectangle {
        color: bgSecondary
        border.color: borderMain
        border.width: 1
        radius: 12
    }

    contentItem: ColumnLayout {
        spacing: 16

        // Başlık
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 36
                height: 36
                radius: 8
                color: "#181818"
                border.color: borderMain
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/icons/clock.svg"
                    width: 18
                    height: 18
                    sourceSize: Qt.size(18, 18)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: t("history_title") || "Parola Geçmişi"
                    color: textMain
                    font.pixelSize: 17
                    font.bold: true
                }
                Text {
                    text: serviceName ? (serviceName + " hesabı için eski parolalar") : "Eski parola kayıtları"
                    color: textMuted
                    font.pixelSize: 12
                }
            }

            Button {
                text: "✕"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                background: Rectangle { color: parent.hovered ? bgHover : "transparent"; radius: 16 }
                contentItem: Text { text: parent.text; color: textMuted; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: historyDialog.close()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: borderMain
        }

        // Geçmiş Listesi
        ListView {
            id: historyListView
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(260, Math.max(80, historyList.length * 64))
            clip: true
            spacing: 8
            model: historyList

            delegate: Rectangle {
                width: historyListView.width
                height: 56
                color: "#141414"
                border.color: borderMain
                radius: 8

                property bool showPwd: false

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: showPwd ? modelData.password : "••••••••••••"
                            color: textMain
                            font.pixelSize: 14
                            font.family: "Monospace"
                            font.bold: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "Değiştirildi: " + (modelData.changedAt ? modelData.changedAt.replace("T", " ").substring(0, 19) : "-")
                            color: textMuted
                            font.pixelSize: 11
                        }
                    }

                    Button {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        icon.source: showPwd ? "qrc:/icons/eye-off.svg" : "qrc:/icons/eye.svg"
                        icon.color: hovered ? "#ffffff" : textMuted
                        display: AbstractButton.IconOnly
                        background: Rectangle { color: parent.hovered ? bgHover : "transparent"; radius: 4 }
                        onClicked: showPwd = !showPwd
                    }

                    Button {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        icon.source: "qrc:/icons/copy.svg"
                        icon.color: hovered ? "#ffffff" : textMuted
                        display: AbstractButton.IconOnly
                        background: Rectangle { color: parent.hovered ? bgHover : "transparent"; radius: 4 }
                        onClicked: {
                            vaultManager.copyToClipboard(modelData.password)
                            showToast(t("toast_copied") || "Parola panoya kopyalandı!")
                        }
                    }
                }
            }
        }

        Text {
            visible: historyList.length === 0
            text: t("history_empty") || "Bu hesap için henüz kaydedilmiş eski parola geçmişi bulunmuyor."
            color: textMuted
            font.pixelSize: 13
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16
            Layout.bottomMargin: 16
        }

        Button {
            text: t("dialog_cancel_btn") || "Kapat"
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            background: Rectangle { color: parent.hovered ? bgHover : "#1c1c1c"; radius: 6; border.color: borderMain }
            contentItem: Text { text: parent.text; color: textMain; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true }
            onClicked: historyDialog.close()
        }
    }
}
