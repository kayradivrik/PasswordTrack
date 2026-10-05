import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: dashboardView
    anchors.fill: parent

    property string selectedCategory: "all"
    property int totpRemaining: vaultManager.getTotpRemainingSeconds()
    property alias searchInput: searchInput
    property alias sortCombo: sortCombo

    readonly property int dashboardMargin: Math.round(width < 900 ? 24 : 36)
    readonly property int dashboardWidth: Math.max(100, Math.round(width - (dashboardMargin * 2)))
    readonly property int tableAvailableWidth: Math.max(10, dashboardWidth - 32 - 176)
    readonly property int colServiceWidth: Math.max(120, Math.floor(tableAvailableWidth * 0.28))
    readonly property int colUsernameWidth: Math.max(140, Math.floor(tableAvailableWidth * 0.38))
    readonly property int colPasswordWidth: Math.max(120, tableAvailableWidth - colServiceWidth - colUsernameWidth)
    readonly property int colActionsWidth: 176

    Connections {
        target: vaultManager
        function onTotpTick(sec) {
            dashboardView.totpRemaining = sec
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: dashboardView.dashboardMargin
        anchors.rightMargin: dashboardView.dashboardMargin
        anchors.topMargin: Math.max(16, Math.min(28, Math.round(parent.height * 0.035)))
        anchors.bottomMargin: Math.max(16, Math.min(28, Math.round(parent.height * 0.035)))
        spacing: parent.height < 650 ? 14 : 20

        // 1. Üst Çubuk (Top Bar)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            Layout.minimumHeight: 38
            Layout.maximumHeight: 38
            Layout.fillHeight: false
            spacing: 12

            Image {
                source: "qrc:/icons/key.svg"
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                sourceSize: Qt.size(26, 26)
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: t("passwords_title") || "Parolalarım"
                color: textMain
                font.pixelSize: 22
                font.bold: true
                font.letterSpacing: 1
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            // Arama Kutusu
            TextField {
                id: searchInput
                placeholderText: t("search_placeholder") || "Kasalarda ara... (Servis veya e-posta)"
                Layout.fillWidth: true
                Layout.preferredWidth: 240
                Layout.maximumWidth: 260
                Layout.minimumWidth: 120
                Layout.preferredHeight: 38
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: TextInput.AlignVCenter
                color: textMain
                font.pixelSize: 13
                leftPadding: 14
                rightPadding: 14
                background: Rectangle {
                    color: "#141414"
                    radius: 6
                    border.color: searchInput.activeFocus ? accent : borderMain
                }
                onTextChanged: loadData()
            }

            // Sıralama
            ComboBox {
                id: sortCombo
                Layout.fillWidth: true
                Layout.preferredWidth: 140
                Layout.maximumWidth: 150
                Layout.minimumWidth: 100
                Layout.preferredHeight: 38
                Layout.alignment: Qt.AlignVCenter
                model: [t("sort_newest"), t("sort_oldest"), t("sort_az"), t("sort_za")]
                background: Rectangle {
                    color: "#141414"
                    radius: 6
                    border.color: sortCombo.down ? accent : borderMain
                }
                contentItem: Text {
                    text: sortCombo.displayText
                    color: textMain
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                }
                onActivated: loadData()
            }

            // Yeni Şifre Ekle Butonu
            Button {
                text: t("add_password_btn") || "Yeni Şifre Ekle"
                Layout.preferredHeight: 38
                Layout.preferredWidth: 140
                Layout.alignment: Qt.AlignVCenter
                background: Rectangle {
                    color: parent.down ? "#cccccc" : (parent.hovered ? accentHover : accent)
                    radius: 6
                }
                contentItem: RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Image {
                        source: "qrc:/icons/plus.svg"
                        sourceSize: Qt.size(14, 14)
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Text {
                        text: t("add_password_btn") || "Yeni Şifre"
                        color: bgMain
                        font.bold: true
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                onClicked: addDialog.open()
                scale: pressed ? 0.96 : (hovered ? 1.02 : 1.0)
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
            }
        }

        // 2. Kategori Çipleri (Kategoriler & Favoriler)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            Layout.minimumHeight: 28
            Layout.maximumHeight: 28
            Layout.fillHeight: false
            spacing: 8

            Repeater {
                model: [
                    { id: "all", label: t("cat_all") || "Tümü" },
                    { id: "favorite", label: "★ " + (t("cat_favorite") || "Favoriler") },
                    { id: "general", label: t("cat_general") || "Genel" },
                    { id: "work", label: t("cat_work") || "İş" },
                    { id: "finance", label: t("cat_finance") || "Finans" },
                    { id: "social", label: t("cat_social") || "Sosyal" },
                    { id: "personal", label: t("cat_personal") || "Kişisel" }
                ]

                delegate: Rectangle {
                    readonly property bool isSelected: selectedCategory === modelData.id
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: catTxt.implicitWidth + 24
                    radius: 14
                    color: isSelected ? accent : (catMa.hovered ? "#222222" : "#141414")
                    border.color: isSelected ? accent : borderMain
                    border.width: 1

                    Text {
                        id: catTxt
                        anchors.centerIn: parent
                        text: modelData.label
                        color: isSelected ? bgMain : (catMa.hovered ? textMain : textMuted)
                        font.pixelSize: 11
                        font.bold: isSelected
                    }

                    MouseArea {
                        id: catMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            selectedCategory = modelData.id
                            loadData()
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }

        // 3. Parola Sağlığı & Filtre Çubuğu
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            Layout.minimumHeight: 38
            Layout.maximumHeight: 38
            Layout.fillHeight: false
            color: wallpaperPath !== "" ? "#d90a0a0a" : "#0d0d0d"
            border.color: borderMain
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 14

                // Sağlık Skoru
                RowLayout {
                    spacing: 8
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        source: "qrc:/icons/shield.svg"
                        sourceSize: Qt.size(14, 14)
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14
                        opacity: 0.8
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: (t("health_score") || "Kasa Sağlığı") + ": %" + healthScore
                        color: textMain
                        font.pixelSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Rectangle {
                        width: 36
                        height: 3
                        radius: 1.5
                        color: "#222222"
                        Layout.alignment: Qt.AlignVCenter
                        Rectangle {
                            width: parent.width * Math.min(1.0, Math.max(0.0, healthScore / 100.0))
                            height: parent.height
                            radius: 1.5
                            color: healthScore >= 80 ? "#ffffff" : (healthScore >= 50 ? "#e5e5e5" : danger)
                        }
                    }
                }

                Rectangle { width: 1; height: 14; color: borderMain; Layout.alignment: Qt.AlignVCenter }

                // Sağlık Filtre Sekmeleri
                RowLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    Repeater {
                        model: [
                            { id: "all", label: t("health_all") || "Tümü", count: totalCount },
                            { id: "reused", label: t("health_reused") || "Tekrar Eden", count: reusedCount },
                            { id: "weak", label: t("health_weak") || "Zayıf", count: weakCount },
                            { id: "pwned", label: t("health_leaked") || "Sızdırılmış", count: pwnedCount }
                        ]

                        delegate: Rectangle {
                            readonly property bool isSelected: healthFilter === modelData.id
                            Layout.preferredHeight: 26
                            Layout.preferredWidth: tabTxt.implicitWidth + 18
                            radius: 4
                            color: isSelected ? "#222222" : (tabMouse.containsMouse ? "#161616" : "transparent")
                            border.color: isSelected ? "#333333" : "transparent"
                            border.width: 1

                            Text {
                                id: tabTxt
                                anchors.centerIn: parent
                                text: modelData.label + " (" + modelData.count + ")"
                                color: isSelected ? textMain : (modelData.count > 0 && modelData.id !== "all" ? "#cccccc" : textMuted)
                                font.pixelSize: 11
                                font.bold: isSelected
                            }

                            MouseArea {
                                id: tabMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    healthFilter = (modelData.id === "all") ? "all" : (healthFilter === modelData.id ? "all" : modelData.id)
                                    loadData()
                                }
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }

        // 4. Tablo Başlığı
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.preferredHeight: 28
            Layout.minimumHeight: 28
            Layout.maximumHeight: 28
            Layout.fillHeight: false
            spacing: 0

            Item {
                Layout.preferredWidth: colServiceWidth
                Layout.preferredHeight: 28
                Layout.fillHeight: false
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: t("col_service") || "SERVİS"
                    color: textMuted
                    font.bold: true
                    font.pixelSize: 11
                    font.letterSpacing: 1
                }
            }

            Item {
                Layout.preferredWidth: colUsernameWidth
                Layout.preferredHeight: 28
                Layout.fillHeight: false
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: t("col_username") || "KULLANICI ADI"
                    color: textMuted
                    font.bold: true
                    font.pixelSize: 11
                    font.letterSpacing: 1
                }
            }

            Item {
                Layout.preferredWidth: colPasswordWidth
                Layout.preferredHeight: 28
                Layout.fillHeight: false
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: (t("col_password") || "PAROLA") + " / 2FA"
                    color: textMuted
                    font.bold: true
                    font.pixelSize: 11
                    font.letterSpacing: 1
                }
            }

            Item {
                Layout.preferredWidth: colActionsWidth
                Layout.preferredHeight: 28
                Layout.fillHeight: false
            }

            Item { Layout.fillWidth: true }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.minimumHeight: 1
            Layout.maximumHeight: 1
            Layout.fillHeight: false
            height: 1
            color: borderMain
        }

        // 5. Parola Listesi (ListView)
        ListView {
            id: passwordList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 150
            clip: true
            spacing: 8
            boundsBehavior: Flickable.StopAtBounds
            footer: Item { width: passwordList.width; height: 64 }

            model: vaultModel

            ScrollBar.vertical: ScrollBar {
                id: listScrollBar
                policy: ScrollBar.AsNeeded
                active: true
                width: 8
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: parent.pressed ? textMain : (parent.hovered ? textMuted : "#33ffffff")
                }
            }

            delegate: Rectangle {
                width: passwordList.width
                height: 58
                color: rowMa.hovered ? bgHover : (wallpaperPath !== "" ? "#d9121212" : "#0f0f0f")
                border.color: (wallpaperPath !== "" && !rowMa.hovered) ? "#26ffffff" : borderMain
                border.width: 1
                radius: 8

                property bool showPassword: false

                MouseArea {
                    id: rowMa
                    anchors.fill: parent
                    hoverEnabled: true
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 0

                    // 1. Kolon: Favori Yıldızı, Servis İkonu ve Adı + URL Linki
                    Item {
                        Layout.preferredWidth: colServiceWidth
                        Layout.fillHeight: true
                        clip: true

                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            // Favori Butonu
                            Text {
                                text: model.isFavorite ? "★" : "☆"
                                color: model.isFavorite ? "#e5e5e5" : "#444444"
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignVCenter
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        vaultManager.toggleFavorite(model.id)
                                        loadData()
                                    }
                                }
                            }

                            // Marka İkonu
                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: 6
                                color: "#141414"
                                border.color: "#262626"
                                border.width: 1

                                readonly property var brandItem: getBrandInfo(model.service)

                                Image {
                                    anchors.centerIn: parent
                                    width: 16
                                    height: 16
                                    sourceSize.width: 16
                                    sourceSize.height: 16
                                    fillMode: Image.PreserveAspectFit
                                    source: parent.brandItem ? parent.brandItem.icon : ""
                                    visible: parent.brandItem !== null
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: (model.service && model.service.length > 0) ? model.service.charAt(0).toUpperCase() : "?"
                                    color: "#888888"
                                    font.pixelSize: 12
                                    font.bold: true
                                    visible: parent.brandItem === null
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: model.service ? model.service : "İsimsiz"
                                    color: textMain
                                    font.pixelSize: 13
                                    font.bold: true
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                // Varsa Tıklanabilir URL
                                Text {
                                    visible: model.url !== undefined && model.url !== ""
                                    text: model.url || ""
                                    color: "#d4d4d4"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var u = model.url
                                            if (!u.startsWith("http://") && !u.startsWith("https://")) u = "https://" + u
                                            Qt.openUrlExternally(u)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 2. Kolon: Kullanıcı Adı / E-Posta
                    Item {
                        Layout.preferredWidth: colUsernameWidth
                        Layout.fillHeight: true
                        clip: true

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.username
                            color: textMuted
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }
                    }

                    // 3. Kolon: Parola, Rozetler & Canlı 2FA/TOTP Rozeti
                    Item {
                        Layout.preferredWidth: colPasswordWidth
                        Layout.fillHeight: true
                        clip: true

                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: showPassword ? model.password : "••••••••••••"
                                color: textMuted
                                font.pixelSize: 13
                                font.family: showPassword ? "Monospace" : "inherit"
                                font.letterSpacing: showPassword ? 0 : 2
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                Layout.maximumWidth: parent.width - (totpPill.visible ? 120 : 40)
                            }

                            // 2FA / TOTP Canlı Kodu Rozeti (Varsa)
                            Rectangle {
                                id: totpPill
                                visible: model.totpSecret !== undefined && model.totpSecret !== ""
                                height: 24
                                width: totpPillRow.width + 14
                                radius: 12
                                color: "#052e16"
                                border.color: "#ffffff"
                                border.width: 1

                                readonly property string totpCode: model.totpSecret ? vaultManager.generateTotp(model.totpSecret) : ""

                                RowLayout {
                                    id: totpPillRow
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        text: totpPill.totpCode
                                        color: "#4ade80"
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: "Monospace"
                                    }

                                    Text {
                                        text: "(" + dashboardView.totpRemaining + "s)"
                                        color: "#86efac"
                                        font.pixelSize: 9
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        vaultManager.copyToClipboard(totpPill.totpCode)
                                        showToast("2FA Kodu (" + totpPill.totpCode + ") panoya kopyalandı!")
                                    }
                                }
                            }

                            // Güvenlik Uyarı Rozeti (üzerine gelince durumu açıklar)
                            Rectangle {
                                id: securityBadge
                                visible: Boolean(model.isPwned || model.isWeak || model.isReused)
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22
                                radius: 5
                                color: (model.isPwned || model.isWeak) ? "#26ff4444" : "#1fffffff"
                                border.color: (model.isPwned || model.isWeak) ? danger : "#e5e5e5"
                                border.width: 1
                                scale: badgeHover.hovered ? 1.12 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100 } }

                                readonly property bool en: appLang === "en"
                                readonly property string statusText: {
                                    var lines = []
                                    if (model.isPwned) lines.push(en ? "⚠ Leaked: found in known data breaches. Change it now!" : "⚠ Sızdırılmış: bilinen veri ihlallerinde bulundu. Hemen değiştirin!")
                                    if (model.isWeak) lines.push(en ? "• Weak password: too short or predictable" : "• Zayıf parola: kısa veya tahmin edilebilir")
                                    if (model.isReused) lines.push(en ? "• Reused: same password on multiple accounts" : "• Tekrar eden parola: birden fazla hesapta aynı")
                                    return lines.join("\n")
                                }

                                Image {
                                    anchors.centerIn: parent
                                    width: 12
                                    height: 12
                                    sourceSize: Qt.size(12, 12)
                                    source: (model.isPwned || model.isWeak) ? "qrc:/icons/alert.svg" : "qrc:/icons/copy.svg"
                                }

                                HoverHandler {
                                    id: badgeHover
                                    cursorShape: Qt.PointingHandCursor
                                }

                                ToolTip {
                                    visible: badgeHover.hovered
                                    delay: 150
                                    text: securityBadge.statusText
                                    contentItem: Text {
                                        text: securityBadge.statusText
                                        color: textMain
                                        font.pixelSize: 12
                                        lineHeight: 1.3
                                    }
                                    background: Rectangle {
                                        color: "#161616"
                                        radius: 6
                                        border.width: 1
                                        border.color: model.isPwned ? danger : borderMain
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }
                    }

                    // 4. Kolon: Aksiyon Butonları
                    Item {
                        Layout.preferredWidth: colActionsWidth
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            // Göster / Gizle
                            Button {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                icon.source: showPassword ? "qrc:/icons/eye-off.svg" : "qrc:/icons/eye.svg"
                                icon.color: hovered ? "#ffffff" : textMuted
                                icon.width: 16
                                icon.height: 16
                                display: AbstractButton.IconOnly
                                ToolTip.visible: hovered
                                ToolTip.text: showPassword ? t("tooltip_hide") : t("tooltip_show")
                                background: Rectangle { color: parent.hovered ? bgHover : "transparent"; radius: 4 }
                                onClicked: showPassword = !showPassword
                            }

                            // Parola Kopyala
                            Button {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                icon.source: "qrc:/icons/copy.svg"
                                icon.color: hovered ? "#ffffff" : textMuted
                                icon.width: 16
                                icon.height: 16
                                display: AbstractButton.IconOnly
                                ToolTip.visible: hovered
                                ToolTip.text: t("tooltip_copy") || "Parolayı Kopyala"
                                background: Rectangle { color: parent.hovered ? bgHover : "transparent"; radius: 4 }
                                onClicked: vaultManager.copyToClipboard(model.password)
                            }

                            // Düzenle
                            Button {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                icon.source: "qrc:/icons/edit.svg"
                                icon.color: hovered ? "#ffffff" : textMuted
                                icon.width: 16
                                icon.height: 16
                                display: AbstractButton.IconOnly
                                ToolTip.visible: hovered
                                ToolTip.text: t("tooltip_edit") || "Düzenle"
                                background: Rectangle { color: parent.hovered ? bgHover : "transparent"; radius: 4 }
                                onClicked: editDialog.openForId(model.id)
                            }

                            // Sil
                            Button {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                icon.source: "qrc:/icons/trash.svg"
                                icon.color: hovered ? danger : textMuted
                                icon.width: 16
                                icon.height: 16
                                display: AbstractButton.IconOnly
                                ToolTip.visible: hovered
                                ToolTip.text: t("tooltip_delete") || "Sil"
                                background: Rectangle { color: parent.hovered ? bgHover : "transparent"; radius: 4 }
                                onClicked: {
                                    vaultManager.deleteEntry(model.id)
                                    loadData()
                                    showToast(t("toast_deleted") || "Şifre silindi.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Sağ Altta Yüzen Ayarlar Butonu
    Button {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: dashboardView.dashboardMargin
        width: 44
        height: 44
        icon.source: "qrc:/icons/settings.svg"
        icon.color: hovered ? "#000000" : textMuted
        icon.width: 22
        icon.height: 22
        display: AbstractButton.IconOnly
        background: Rectangle {
            color: parent.hovered ? textMain : bgSecondary
            radius: 22
            border.color: borderMain
        }
        onClicked: appState = 3
        scale: pressed ? 0.9 : (hovered ? 1.05 : 1.0)
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
    }
}
