import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: addDialog
    x: (parent.width - width * scale) / 2
    y: (parent.height - height * scale) / 2
    width: Math.min(560, parent.width / uiScale - 32)
    scale: Math.min(1.2, Math.max(0.85, uiScale))
    transformOrigin: Item.Center
    parent: Overlay.overlay
    modal: true

    property bool showPassword: false
    property bool showAdvancedGen: false
    property bool showExtraFields: false
    property bool genUsePassphrase: false
    property bool genUpper: true
    property bool genLower: true
    property bool genDigits: true
    property bool genSymbols: true
    property int genLength: 16
    property int genWords: 4

    readonly property var addBrandInfo: getBrandInfo(addService.text)

    signal saved()

    onAboutToShow: {
        showPassword = false
        showAdvancedGen = false
        showExtraFields = false
        addService.text = ""
        addUsername.text = ""
        addPassword.text = ""
        addUrl.text = ""
        addNotes.text = ""
        addTotp.text = ""
        addCategory.currentIndex = 0
        addFavSwitch.checked = false
        addService.forceActiveFocus()
    }

    background: Rectangle {
        color: bgSecondary
        border.color: borderMain
        border.width: 1
        radius: 12
    }

    contentItem: ScrollView {
        id: addScrollView
        implicitWidth: addDialog.width - 40
        implicitHeight: Math.min(560, addColLayout.implicitHeight + 20)
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
            id: addColLayout
            width: addScrollView.width - 20
            spacing: 14

            // Başlık Çubuğu
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    width: 52
                    height: 52
                    radius: 14
                    color: addDialog.addBrandInfo ? "#141414" : accent
                    border.color: addDialog.addBrandInfo ? accent : "transparent"
                    border.width: addDialog.addBrandInfo ? 1.5 : 0

                    Image {
                        anchors.centerIn: parent
                        width: 28
                        height: 28
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectFit
                        source: addDialog.addBrandInfo ? addDialog.addBrandInfo.icon : ""
                        visible: addDialog.addBrandInfo !== null
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        sourceSize: Qt.size(26, 26)
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/icons/plus.svg"
                        visible: addDialog.addBrandInfo === null
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    Text {
                        text: t("dialog_add_title") || "Yeni Şifre Ekle"
                        color: textMain
                        font.pixelSize: 21
                        font.bold: true
                        font.letterSpacing: 0.5
                    }
                    Text {
                        text: addDialog.addBrandInfo ? (addDialog.addBrandInfo.name + " hesabı ekleniyor") : "Kasanıza yeni bir hesap ve parola ekleyin"
                        color: addDialog.addBrandInfo ? "#a3a3a3" : textMuted
                        font.pixelSize: 12
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
                    onClicked: addDialog.close()
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: borderMain }

            // Servis Adı
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text { text: t("dialog_service_label") || "Servis / Platform"; color: textMuted; font.pixelSize: 12; font.bold: true }
                TextField {
                    id: addService
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    placeholderText: t("dialog_service_placeholder") || "Örn: Google, Netflix, GitHub..."
                    color: textMain
                    font.pixelSize: 13
                    background: Rectangle { color: "#141414"; radius: 6; border.color: addService.activeFocus ? accent : borderMain }
                }

                // Marka Öneri Çipleri (Yatay Liste)
                ListView {
                    id: brandChipsList
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    orientation: ListView.Horizontal
                    spacing: 8
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }
                    model: getMatchingBrands(addService.text)

                    delegate: Rectangle {
                        height: 30
                        width: chipRow.width + 16
                        radius: 15
                        color: chipMa.hovered ? "#262626" : "#141414"
                        border.color: (addDialog.addBrandInfo && addDialog.addBrandInfo.id === modelData.id) ? accent : borderMain
                        border.width: 1

                        Row {
                            id: chipRow
                            anchors.centerIn: parent
                            spacing: 6
                            Image { width: 14; height: 14; sourceSize: Qt.size(14, 14); source: modelData.icon }
                            Text { text: modelData.name; color: textMain; font.pixelSize: 11; font.bold: true }
                        }

                        MouseArea {
                            id: chipMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: addService.text = modelData.name
                        }
                    }
                }
            }

            // Kullanıcı Adı
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text { text: t("dialog_username_label") || "Kullanıcı Adı veya E-Posta"; color: textMuted; font.pixelSize: 12; font.bold: true }
                TextField {
                    id: addUsername
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    placeholderText: t("dialog_username_placeholder") || "Örn: ornek@gmail.com"
                    color: textMain
                    font.pixelSize: 13
                    background: Rectangle { color: "#141414"; radius: 6; border.color: addUsername.activeFocus ? accent : borderMain }
                }
            }

            // Parola Alanı & Üretici Butonu
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: t("dialog_password_label") || "Parola"; color: textMuted; font.pixelSize: 12; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: showAdvancedGen ? "⚙ Ayarları Kapat" : "⚙ Gelişmiş Üretici"
                        flat: true
                        background: Item {}
                        contentItem: Text { text: parent.text; color: accent; font.pixelSize: 11; font.bold: true }
                        onClicked: showAdvancedGen = !showAdvancedGen
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    TextField {
                        id: addPassword
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        echoMode: addDialog.showPassword ? TextInput.Normal : TextInput.Password
                        placeholderText: t("dialog_password_placeholder") || "Güçlü bir parola girin"
                        color: textMain
                        font.pixelSize: 13
                        font.family: addDialog.showPassword ? "Monospace" : "inherit"
                        background: Rectangle { color: "#141414"; radius: 6; border.color: addPassword.activeFocus ? accent : borderMain }
                    }

                    Button {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        icon.source: addDialog.showPassword ? "qrc:/icons/eye-off.svg" : "qrc:/icons/eye.svg"
                        icon.color: hovered ? "#ffffff" : textMuted
                        display: AbstractButton.IconOnly
                        background: Rectangle { color: parent.hovered ? bgHover : "#141414"; radius: 6; border.color: borderMain }
                        onClicked: addDialog.showPassword = !addDialog.showPassword
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
                            if (genUsePassphrase) {
                                addPassword.text = passwordGen.generatePassphrase(genWords, "-")
                            } else {
                                addPassword.text = passwordGen.generate(genLength, genUpper, genLower, genDigits, genSymbols)
                            }
                            addDialog.showPassword = true
                        }
                    }
                }

                // Canlı Güç Göstergesi
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    readonly property int score: vaultManager.checkPasswordStrength(addPassword.text)
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

            // Gelişmiş Şifre Üretici Paneli (CSPRNG Seçenekleri)
            Rectangle {
                Layout.fillWidth: true
                visible: showAdvancedGen
                color: "#111111"
                border.color: borderMain
                radius: 8
                Layout.preferredHeight: advGenCol.implicitHeight + 20

                ColumnLayout {
                    id: advGenCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // Mod Seçici: Karakter vs Passphrase
                    RowLayout {
                        Layout.fillWidth: true
                        Button {
                            text: "Karakter (CSPRNG)"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            background: Rectangle { color: !genUsePassphrase ? accent : "#1a1a1a"; radius: 4 }
                            contentItem: Text { text: parent.text; color: !genUsePassphrase ? bgMain : textMuted; font.bold: true; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter }
                            onClicked: genUsePassphrase = false
                        }
                        Button {
                            text: "Kelime Öbeği (Passphrase)"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            background: Rectangle { color: genUsePassphrase ? accent : "#1a1a1a"; radius: 4 }
                            contentItem: Text { text: parent.text; color: genUsePassphrase ? bgMain : textMuted; font.bold: true; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter }
                            onClicked: genUsePassphrase = true
                        }
                    }

                    // Karakter Filtreleri
                    RowLayout {
                        visible: !genUsePassphrase
                        Layout.fillWidth: true
                        spacing: 8
                        CheckBox {
                            text: "A-Z"
                            checked: genUpper
                            onCheckedChanged: genUpper = checked
                            contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 11; leftPadding: 20 }
                        }
                        CheckBox {
                            text: "a-z"
                            checked: genLower
                            onCheckedChanged: genLower = checked
                            contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 11; leftPadding: 20 }
                        }
                        CheckBox {
                            text: "0-9"
                            checked: genDigits
                            onCheckedChanged: genDigits = checked
                            contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 11; leftPadding: 20 }
                        }
                        CheckBox {
                            text: "!@#$"
                            checked: genSymbols
                            onCheckedChanged: genSymbols = checked
                            contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 11; leftPadding: 20 }
                        }
                    }

                    // Uzunluk Kaydırıcısı
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: genUsePassphrase ? ("Kelime: " + genWords) : ("Uzunluk: " + genLength)
                            color: textMuted
                            font.pixelSize: 12
                            Layout.preferredWidth: 80
                        }
                        Slider {
                            Layout.fillWidth: true
                            from: genUsePassphrase ? 2 : 8
                            to: genUsePassphrase ? 8 : 48
                            stepSize: 1
                            value: genUsePassphrase ? genWords : genLength
                            onMoved: {
                                if (genUsePassphrase) genWords = value
                                else genLength = value
                            }
                        }
                    }
                }
            }

            // Ekstra Alanları Aç/Kapat Butonu
            Button {
                text: showExtraFields ? "▲ Daha Az Alan Göster" : "▼ Ekstra Alanlar (URL, Notlar, 2FA/TOTP, Kategori)"
                Layout.fillWidth: true
                flat: true
                background: Rectangle { color: parent.hovered ? bgHover : "transparent"; radius: 6 }
                contentItem: Text { text: parent.text; color: textMuted; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                onClicked: showExtraFields = !showExtraFields
            }

            // Ek Veri Alanları Paneli
            ColumnLayout {
                Layout.fillWidth: true
                visible: showExtraFields
                spacing: 12

                // Web Sitesi (URL)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Web Sitesi (URL)"; color: textMuted; font.pixelSize: 12; font.bold: true }
                    TextField {
                        id: addUrl
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        placeholderText: "https://example.com"
                        color: textMain
                        font.pixelSize: 13
                        background: Rectangle { color: "#141414"; radius: 6; border.color: addUrl.activeFocus ? accent : borderMain }
                    }
                }

                // 2FA / TOTP Anahtarı
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    RowLayout {
                        id: addTotpRow
                        Layout.fillWidth: true
                        Text { text: "2FA / TOTP Gizli Anahtarı"; color: textMuted; font.pixelSize: 12; font.bold: true }
                        Item { Layout.fillWidth: true }
                        readonly property string previewCode: vaultManager.generateTotp(addTotp.text)
                        Text {
                            visible: addTotpRow.previewCode !== ""
                            text: "Önizleme Kod: " + addTotpRow.previewCode
                            color: "#ffffff"
                            font.family: "Monospace"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                    TextField {
                        id: addTotp
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        placeholderText: "Örn: JBSWY3DPEHPK3PXP (Base32 Anahtarı)"
                        color: textMain
                        font.pixelSize: 13
                        font.family: "Monospace"
                        background: Rectangle { color: "#141414"; radius: 6; border.color: addTotp.activeFocus ? accent : borderMain }
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
                            id: addCategory
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            model: ["general", "work", "finance", "social", "personal"]
                            displayText: {
                                var map = { "general": "Genel", "work": "İş", "finance": "Finans", "social": "Sosyal Medya", "personal": "Kişisel" }
                                return map[currentText] || currentText
                            }
                            background: Rectangle { color: "#141414"; radius: 6; border.color: borderMain }
                            contentItem: Text { text: addCategory.displayText; color: textMain; font.pixelSize: 13; leftPadding: 12; verticalAlignment: Text.AlignVCenter }
                        }
                    }

                    ColumnLayout {
                        spacing: 4
                        Text { text: "Favori"; color: textMuted; font.pixelSize: 12; font.bold: true }
                        Button {
                            id: addFavSwitch
                            checkable: true
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 38
                            text: checked ? "★ Favori" : "☆ Normal"
                            background: Rectangle {
                                radius: 6
                                color: addFavSwitch.checked ? "#1fffffff" : (addFavSwitch.hovered ? "#1f1f1f" : "#141414")
                                border.color: addFavSwitch.checked ? "#e5e5e5" : borderMain
                            }
                            contentItem: Text {
                                text: addFavSwitch.text
                                color: addFavSwitch.checked ? "#e5e5e5" : textMuted
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
                        id: addNotes
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        placeholderText: "Yalnızca şifreli kasada saklanacak özel notlar..."
                        color: textMain
                        font.pixelSize: 12
                        wrapMode: TextEdit.Wrap
                        background: Rectangle { color: "#141414"; radius: 6; border.color: addNotes.activeFocus ? accent : borderMain }
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
                    onClicked: addDialog.close()
                }

                Button {
                    text: t("dialog_save_btn") || "Kaydet"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle { color: parent.hovered ? accentHover : accent; radius: 6 }
                    contentItem: Text { text: parent.text; color: bgMain; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.bold: true }
                    onClicked: {
                        if (addService.text.trim() === "" || addPassword.text === "") {
                            showToast("Lütfen servis adı ve parola alanlarını doldurun!")
                            return
                        }
                        var cat = addCategory.currentText || "general"
                        if (vaultManager.addEntry(addService.text, addUsername.text, addPassword.text,
                                                 addUrl.text, addNotes.text, addTotp.text, cat, addFavSwitch.checked)) {
                            loadData()
                            addDialog.close()
                            showToast(t("toast_saved") || "Şifre başarıyla kaydedildi.")
                            addDialog.saved()
                        } else {
                            showToast("Kayıt sırasında hata oluştu!")
                        }
                    }
                }
            }
        }
    }
}
