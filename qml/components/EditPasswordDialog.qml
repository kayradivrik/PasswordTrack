import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: editDialog
    x: (parent.width - width * scale) / 2
    y: (parent.height - height * scale) / 2
    width: Math.min(560, parent.width / uiScale - 32)
    scale: Math.min(1.2, Math.max(0.85, uiScale))
    transformOrigin: Item.Center
    parent: Overlay.overlay
    modal: true

    property int entryId: 0
    property bool showPassword: false
    property bool showAdvancedGen: false
    property bool showExtraFields: true

    property alias serviceText: editService.text
    property alias usernameText: editUsername.text
    property alias passwordText: editPassword.text
    property alias urlText: editUrl.text
    property alias notesText: editNotes.text
    property alias totpText: editTotp.text

    readonly property var editBrandInfo: getBrandInfo(editService.text)

    function openForId(id) {
        entryId = id
        var data = vaultManager.getEntryById(id)
        if (!data || data.id === undefined) return

        editService.text = data.service || ""
        editUsername.text = data.username || ""
        editPassword.text = data.password || ""
        editUrl.text = data.url || ""
        editNotes.text = data.notes || ""
        editTotp.text = data.totpSecret || ""
        editFavSwitch.checked = Boolean(data.isFavorite)

        var catIndex = editCategory.model.indexOf(data.category || "general")
        editCategory.currentIndex = catIndex >= 0 ? catIndex : 0

        showPassword = false
        showAdvancedGen = false
        open()
    }

    background: Rectangle {
        color: bgSecondary
        border.color: borderMain
        border.width: 1
        radius: 12
    }

    contentItem: ScrollView {
        id: editScrollView
        implicitWidth: editDialog.width - 40
        implicitHeight: Math.min(560, editColLayout.implicitHeight + 20)
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 8
            contentItem: Rectangle {
                implicitWidth: 6
                implicitHeight: 100
                radius: 3
                color: parent.pressed ? textMain : (parent.hovered ? textMuted : "#33ffffff")
            }
        }

        ColumnLayout {
            id: editColLayout
            width: editScrollView.width - 20
            spacing: 14

            // Başlık
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    width: 52
                    height: 52
                    radius: 14
                    color: editDialog.editBrandInfo ? "#141414" : accent
                    border.color: editDialog.editBrandInfo ? accent : "transparent"
                    border.width: editDialog.editBrandInfo ? 1.5 : 0

                    Image {
                        anchors.centerIn: parent
                        width: 28
                        height: 28
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        source: editDialog.editBrandInfo ? editDialog.editBrandInfo.icon : ""
                        visible: editDialog.editBrandInfo !== null
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        sourceSize: Qt.size(26, 26)
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/icons/edit.svg"
                        visible: editDialog.editBrandInfo === null
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    Text {
                        text: t("dialog_edit_title") || "Şifreyi Düzenle"
                        color: textMain
                        font.pixelSize: 21
                        font.bold: true
                        font.letterSpacing: 0.5
                    }
                    Text {
                        text: editDialog.editBrandInfo ? (editDialog.editBrandInfo.name + " hesabı güncelleniyor") : "Kayıtlı hesap detaylarını güncelleyin"
                        color: editDialog.editBrandInfo ? "#a3a3a3" : textMuted
                        font.pixelSize: 12
                    }
                }

                // Parola Geçmişi Butonu
                Button {
                    text: "🕒 Geçmiş"
                    Layout.preferredHeight: 32
                    background: Rectangle { color: parent.hovered ? bgHover : "#1c1c1c"; radius: 6; border.color: borderMain }
                    contentItem: Text { text: parent.text; color: accent; font.pixelSize: 11; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        historyDialog.openForEntry(entryId, editService.text)
                    }
                }

                Button {
                    id: closeBtn
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    Layout.alignment: Qt.AlignTop
                    background: Rectangle {
                        radius: 17
                        color: closeBtn.down ? "#33ff4444" : (closeBtn.hovered ? "#1fff4444" : "#141414")
                        border.width: 1
                        border.color: closeBtn.hovered ? danger : borderMain
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                    }
                    contentItem: Item {
                        // Çarpı işareti: iki çapraz çizgi (font bağımsız, tam ortalı)
                        Rectangle { anchors.centerIn: parent; width: 14; height: 2; radius: 1; rotation: 45;  color: closeBtn.hovered ? danger : textMuted }
                        Rectangle { anchors.centerIn: parent; width: 14; height: 2; radius: 1; rotation: -45; color: closeBtn.hovered ? danger : textMuted }
                    }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    onClicked: editDialog.close()
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: borderMain }

            // Servis Adı
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text { text: t("dialog_service_label") || "Servis / Platform"; color: textMuted; font.pixelSize: 12; font.bold: true }
                TextField {
                    id: editService
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    color: textMain
                    font.pixelSize: 13
                    background: Rectangle { color: "#141414"; radius: 6; border.color: editService.activeFocus ? accent : borderMain }
                }
            }

            // Kullanıcı Adı
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text { text: t("dialog_username_label") || "Kullanıcı Adı veya E-Posta"; color: textMuted; font.pixelSize: 12; font.bold: true }
                TextField {
                    id: editUsername
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    color: textMain
                    font.pixelSize: 13
                    background: Rectangle { color: "#141414"; radius: 6; border.color: editUsername.activeFocus ? accent : borderMain }
                }
            }

            // Parola Alanı & Üretici
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: t("dialog_password_label") || "Parola"; color: textMuted; font.pixelSize: 12; font.bold: true }
                    Item { Layout.fillWidth: true }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    TextField {
                        id: editPassword
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        echoMode: editDialog.showPassword ? TextInput.Normal : TextInput.Password
                        color: textMain
                        font.pixelSize: 13
                        font.family: editDialog.showPassword ? "Monospace" : "inherit"
                        background: Rectangle { color: "#141414"; radius: 6; border.color: editPassword.activeFocus ? accent : borderMain }
                    }

                    Button {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        icon.source: editDialog.showPassword ? "qrc:/icons/eye-off.svg" : "qrc:/icons/eye.svg"
                        icon.color: hovered ? "#ffffff" : textMuted
                        display: AbstractButton.IconOnly
                        background: Rectangle { color: parent.hovered ? bgHover : "#141414"; radius: 6; border.color: borderMain }
                        onClicked: editDialog.showPassword = !editDialog.showPassword
                    }

                    Button {
                        Layout.preferredHeight: 38
                        Layout.preferredWidth: 80
                        background: Rectangle { color: parent.hovered ? accentHover : accent; radius: 6 }
                        contentItem: RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Image { source: "qrc:/icons/dice.svg"; sourceSize: Qt.size(14, 14); width: 14; height: 14 }
                            Text { text: t("dialog_generate_btn") || "Üret"; color: bgMain; font.bold: true; font.pixelSize: 12 }
                        }
                        onClicked: {
                            editPassword.text = passwordGen.generate(16, true, true, true, true)
                            editDialog.showPassword = true
                        }
                    }
                }

                // Canlı Güç Göstergesi
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    readonly property int score: vaultManager.checkPasswordStrength(editPassword.text)
                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: 1.5
                        color: parent.score >= 1 ? (parent.score >= 3 ? "#ffffff" : "#e5e5e5") : "#222222"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: 1.5
                        color: parent.score >= 2 ? (parent.score >= 3 ? "#ffffff" : "#e5e5e5") : "#222222"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: 1.5
                        color: parent.score >= 3 ? "#ffffff" : "#222222"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: 1.5
                        color: parent.score >= 4 ? "#ffffff" : "#222222"
                    }
                }
            }

            // Ek Veri Alanları
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                // Web Sitesi (URL)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Web Sitesi (URL)"; color: textMuted; font.pixelSize: 12; font.bold: true }
                    TextField {
                        id: editUrl
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        placeholderText: "https://example.com"
                        color: textMain
                        font.pixelSize: 13
                        background: Rectangle { color: "#141414"; radius: 6; border.color: editUrl.activeFocus ? accent : borderMain }
                    }
                }

                // 2FA / TOTP Anahtarı
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    RowLayout {
                        id: editTotpRow
                        Layout.fillWidth: true
                        Text { text: "2FA / TOTP Gizli Anahtarı"; color: textMuted; font.pixelSize: 12; font.bold: true }
                        Item { Layout.fillWidth: true }
                        readonly property string previewCode: vaultManager.generateTotp(editTotp.text)
                        Text {
                            visible: editTotpRow.previewCode !== ""
                            text: "Canlı Kod: " + editTotpRow.previewCode
                            color: "#ffffff"
                            font.family: "Monospace"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                    TextField {
                        id: editTotp
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        placeholderText: "Base32 Gizli Anahtarı (Örn: JBSWY3DPEHPK3PXP)"
                        color: textMain
                        font.pixelSize: 13
                        font.family: "Monospace"
                        background: Rectangle { color: "#141414"; radius: 6; border.color: editTotp.activeFocus ? accent : borderMain }
                    }
                }

                // Kategori ve Favori
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text { text: "Kategori"; color: textMuted; font.pixelSize: 12; font.bold: true }
                        ComboBox {
                            id: editCategory
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            model: ["general", "work", "finance", "social", "personal"]
                            displayText: {
                                var map = { "general": "Genel", "work": "İş", "finance": "Finans", "social": "Sosyal Medya", "personal": "Kişisel" }
                                return map[currentText] || currentText
                            }
                            background: Rectangle { color: "#141414"; radius: 6; border.color: borderMain }
                            contentItem: Text { text: editCategory.displayText; color: textMain; font.pixelSize: 13; leftPadding: 12; verticalAlignment: Text.AlignVCenter }
                        }
                    }

                    ColumnLayout {
                        spacing: 4
                        Text { text: "Favori"; color: textMuted; font.pixelSize: 12; font.bold: true }
                        Button {
                            id: editFavSwitch
                            checkable: true
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 38
                            text: checked ? "★ Favori" : "☆ Normal"
                            background: Rectangle {
                                radius: 6
                                color: editFavSwitch.checked ? "#1fffffff" : (editFavSwitch.hovered ? "#1f1f1f" : "#141414")
                                border.color: editFavSwitch.checked ? "#e5e5e5" : borderMain
                            }
                            contentItem: Text {
                                text: editFavSwitch.text
                                color: editFavSwitch.checked ? "#e5e5e5" : textMuted
                                font.bold: true
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // Gizli Notlar
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Gizli Notlar / Güvenlik Soruları"; color: textMuted; font.pixelSize: 12; font.bold: true }
                    TextArea {
                        id: editNotes
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        placeholderText: "Özel notlar..."
                        color: textMain
                        font.pixelSize: 12
                        wrapMode: TextEdit.Wrap
                        background: Rectangle { color: "#141414"; radius: 6; border.color: editNotes.activeFocus ? accent : borderMain }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: borderMain }

            // Alt Butonlar
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    text: t("dialog_cancel_btn") || "İptal"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle { color: parent.hovered ? bgHover : "#181818"; radius: 6; border.color: borderMain }
                    contentItem: Text { text: parent.text; color: textMuted; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true }
                    onClicked: editDialog.close()
                }

                Button {
                    text: t("dialog_update_btn") || "Değişiklikleri Kaydet"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle { color: parent.hovered ? accentHover : accent; radius: 6 }
                    contentItem: Text { text: parent.text; color: bgMain; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true }
                    onClicked: {
                        if (editService.text.trim() === "" || editPassword.text === "") {
                            showToast("Lütfen servis adı ve parola alanlarını doldurun!")
                            return
                        }
                        var cat = editCategory.currentText || "general"
                        if (vaultManager.updateEntry(entryId, editService.text, editUsername.text, editPassword.text,
                                                    editUrl.text, editNotes.text, editTotp.text, cat, editFavSwitch.checked)) {
                            loadData()
                            editDialog.close()
                            showToast(t("toast_updated") || "Şifre güncellendi.")
                        } else {
                            showToast("Güncelleme sırasında hata oluştu!")
                        }
                    }
                }
            }
        }
    }
}
