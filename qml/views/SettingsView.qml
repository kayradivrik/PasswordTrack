import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

Item {
    id: settingsView
    anchors.fill: parent
    opacity: 0
    scale: 0.98
    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2.0 } }
    Component.onCompleted: {
        opacity = 1
        scale = 1
    }

    // CSV İçe Aktarma Dosya Seçici
    FileDialog {
        id: importCsvFileDialog
        title: "Şifreleri İçe Aktar (Chrome, Firefox, Bitwarden, VoidPass CSV)"
        fileMode: FileDialog.OpenFile
        nameFilters: ["CSV Dosyaları (*.csv)", "Tüm Dosyalar (*)"]
        onAccepted: {
            var res = vaultManager.importFromCSV(selectedFile)
            if (res.success) {
                loadData()
                showToast(res.importedCount + " adet parola başarıyla içe aktarıldı!" + (res.failedCount > 0 ? (" (" + res.failedCount + " başarısız)") : ""))
            } else {
                showToast("CSV içe aktarma başarısız oldu veya geçersiz dosya biçimi!")
            }
        }
    }

    // Acil Durum Kurtarma Kiti Kaydetme Seçici
    FileDialog {
        id: emergencyKitFileDialog
        title: "Acil Durum Kurtarma Kitini Kaydet (HTML / PDF)"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "html"
        nameFilters: ["HTML Belgesi (*.html)"]
        onAccepted: {
            if (vaultManager.generateEmergencyKit(selectedFile)) {
                showToast("Acil Durum Kurtarma Kiti başarıyla oluşturuldu!")
                Qt.openUrlExternally(selectedFile)
            } else {
                showToast("Kurtarma kiti oluşturulurken hata oluştu!")
            }
        }
    }

    // Duvar Kağıdı Seçici
    FileDialog {
        id: wallpaperDialog
        title: "Arka Plan Görseli Seç"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Resim Dosyaları (*.png *.jpg *.jpeg *.webp)"]
        onAccepted: {
            wallpaperPath = selectedFile
            vaultManager.setWallpaper(selectedFile)
            if (wallpaperOpacity > 0.80 || wallpaperOpacity <= 0.0) {
                wallpaperOpacity = 0.20
                vaultManager.setWallpaperOpacity(0.20)
            }
        }
    }

    // Kasa Sıfırlama Onay Diyaloğu
    Dialog {
        id: wipeDialog
        title: "Kasa Sıfırlama Onayı"
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 380
        modal: true
        background: Rectangle { color: bgSecondary; border.color: danger; radius: 8 }
        contentItem: ColumnLayout {
            spacing: 16
            Text { text: "Kasayı Sıfırla?"; color: danger; font.pixelSize: 16; font.bold: true }
            Text { text: "Tüm şifreleriniz ve kasanız kalıcı olarak silinecek. Bu işlem geri alınamaz!"; color: textMain; wrapMode: Text.WordWrap; Layout.fillWidth: true; font.pixelSize: 13 }
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                SettingsButton {
                    text: "İptal"
                    Layout.fillWidth: true
                    background: Rectangle { color: bgHover; radius: 6 }
                    contentItem: Text { text: parent.text; color: textMain; horizontalAlignment: Text.AlignHCenter }
                    onClicked: wipeDialog.close()
                }
                SettingsButton {
                    text: "Evet, Sıfırla"
                    Layout.fillWidth: true
                    background: Rectangle { color: danger; radius: 6 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                    onClicked: {
                        vaultManager.wipeVault()
                        vaultModel.clear()
                        wipeDialog.close()
                        appState = 0
                        showToast("Kasa başarıyla sıfırlandı.")
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 24
        anchors.bottomMargin: 16
        anchors.leftMargin: Math.max(20, (parent.width - 860) / 2)
        anchors.rightMargin: Math.max(20, (parent.width - 860) / 2)
        spacing: 16

        // Üst Başlık & Geri Butonu
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            SettingsButton {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                icon.source: "qrc:/icons/back.svg"
                icon.color: hovered ? "#000000" : textMain
                icon.width: 20
                icon.height: 20
                display: AbstractButton.IconOnly
                background: Rectangle {
                    color: parent.hovered ? textMain : "transparent"
                    radius: 20
                    border.color: borderMain
                }
                onClicked: appState = 2
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: t("settings_title") || "Ayarlar"
                    color: textMain
                    font.pixelSize: 22
                    font.bold: true
                    font.letterSpacing: 1
                }
                Text {
                    text: t("settings_subtitle") || "Görünüm, güvenlik ve veri yönetimi tercihlerinizi yapılandırın"
                    color: textMuted
                    font.pixelSize: 12
                }
            }
        }

        // Kaydırılabilir Ayarlar Listesi
        ScrollView {
            id: settingsScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: settingsScroll.availableWidth - 8
                spacing: 14

                // ========================================================
                // 1. BÖLÜM: GÖRÜNÜM & ARAYÜZ
                // ========================================================
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    spacing: 8
                    Rectangle { width: 3; height: 12; radius: 1.5; color: accent }
                    Text { text: t("settings_cat_appearance") || "GÖRÜNÜM & ARAYÜZ"; color: "#888888"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.5 }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#222222" }
                }

                // Dil Seçimi
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    color: parent.hov ? bgHover : bgSecondary
                    border.color: parent.hov ? "#444444" : borderMain
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {

                        width: 3

                        height: parent.height * 0.4

                        anchors.left: parent.left

                        anchors.verticalCenter: parent.verticalCenter

                        color: accent

                        radius: 1.5

                        opacity: parent.hov ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: t("settings_lang_title") || "Uygulama Dili"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text { text: t("settings_lang_desc") || "Türkçe veya İngilizce"; color: textMuted; font.pixelSize: 12 }
                        }

                        RowLayout {
                            spacing: 10
                            SettingsButton {
                                text: "Türkçe"
                                highlighted: appLang === "tr"
                                onClicked: { appLang = "tr"; vaultManager.setLanguage("tr"); showToast(t("toast_lang_tr")) }
                            }
                            SettingsButton {
                                text: "English"
                                highlighted: appLang === "en"
                                onClicked: { appLang = "en"; vaultManager.setLanguage("en"); showToast(t("toast_lang_en")) }
                            }
                        }
                    }
                }

                // Arayüz Ölçeği
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 88
                    color: parent.hov ? bgHover : bgSecondary
                    border.color: parent.hov ? "#444444" : borderMain
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {

                        width: 3

                        height: parent.height * 0.4

                        anchors.left: parent.left

                        anchors.verticalCenter: parent.verticalCenter

                        color: accent

                        radius: 1.5

                        opacity: parent.hov ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.preferredWidth: 260
                            spacing: 4
                            Text { text: t("settings_scale_title") || "Arayüz Ölçeği"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text { text: "%" + Math.round(uiScale * 100); color: accent; font.pixelSize: 12; font.bold: true }
                        }

                        Slider {
                            Layout.fillWidth: true
                            from: 0.85
                            to: 1.35
                            stepSize: 0.05
                            value: uiScale
                            onMoved: {
                                uiScale = value
                                vaultManager.setUiScale(value)
                            }
                        }
                    }
                }

                // Duvar Kağıdı
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 88
                    color: parent.hov ? bgHover : bgSecondary
                    border.color: parent.hov ? "#444444" : borderMain
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {

                        width: 3

                        height: parent.height * 0.4

                        anchors.left: parent.left

                        anchors.verticalCenter: parent.verticalCenter

                        color: accent

                        radius: 1.5

                        opacity: parent.hov ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: t("settings_wallpaper_title") || "Arka Plan Görseli"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text { text: wallpaperPath === "" ? "Varsayılan minimalist siyah" : "Özel arka plan aktif"; color: textMuted; font.pixelSize: 12 }
                        }

                        RowLayout {
                            spacing: 10
                            SettingsButton {
                                text: wallpaperPath !== "" ? (t("settings_wallpaper_remove") || "Kaldır") : (t("settings_wallpaper_select") || "Görsel Seç")
                                onClicked: {
                                    if (wallpaperPath !== "") {
                                        wallpaperPath = ""
                                        vaultManager.setWallpaper("")
                                    } else {
                                        wallpaperDialog.open()
                                    }
                                }
                            }
                        }
                    }
                }

                // Duvar Kağıdı Saydamlığı (Wallpaper Opacity Slider)
                Rectangle {
                    visible: wallpaperPath !== ""
                    Layout.fillWidth: true
                    Layout.preferredHeight: 88
                    color: bgSecondary
                    property bool hov: false
                    border.color: hov ? "#3a3a3a" : borderMain
                    radius: 8
                    HoverHandler { onHoveredChanged: parent.hov = hovered }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.preferredWidth: 260
                            spacing: 4
                            Text { text: t("settings_wallpaper_opacity") || "Görsel Saydamlığı"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text { 
                                text: "%" + Math.round(wallpaperOpacity * 100) + (wallpaperOpacity <= 0.25 ? " (Önerilen • Net Okunabilirlik)" : "")
                                color: accent
                                font.pixelSize: 12
                                font.bold: true 
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Slider {
                                id: wallpaperOpacitySlider
                                Layout.fillWidth: true
                                from: 0.05
                                to: 1.00
                                stepSize: 0.05
                                value: wallpaperOpacity
                                onMoved: {
                                    wallpaperOpacity = value
                                    vaultManager.setWallpaperOpacity(value)
                                }
                            }

                            RowLayout {
                                spacing: 6
                                SettingsButton {
                                    text: "%15"
                                    Layout.preferredHeight: 32
                                    Layout.preferredWidth: 46
                                    highlighted: Math.abs(wallpaperOpacity - 0.15) < 0.03
                                    onClicked: {
                                        wallpaperOpacity = 0.15
                                        vaultManager.setWallpaperOpacity(0.15)
                                    }
                                }
                                SettingsButton {
                                    text: "%30"
                                    Layout.preferredHeight: 32
                                    Layout.preferredWidth: 46
                                    highlighted: Math.abs(wallpaperOpacity - 0.30) < 0.03
                                    onClicked: {
                                        wallpaperOpacity = 0.30
                                        vaultManager.setWallpaperOpacity(0.30)
                                    }
                                }
                                SettingsButton {
                                    text: "%50"
                                    Layout.preferredHeight: 32
                                    Layout.preferredWidth: 46
                                    highlighted: Math.abs(wallpaperOpacity - 0.50) < 0.03
                                    onClicked: {
                                        wallpaperOpacity = 0.50
                                        vaultManager.setWallpaperOpacity(0.50)
                                    }
                                }
                            }
                        }
                    }
                }

                // ========================================================
                // 2. BÖLÜM: GÜVENLİK & KORUMA
                // ========================================================
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 12
                    spacing: 8
                    Rectangle { width: 3; height: 12; radius: 1.5; color: accent }
                    Text { text: t("settings_cat_security") || "GÜVENLİK & KORUMA"; color: "#888888"; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.5 }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#222222" }
                }

                // Ana Parolayı Değiştir
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    color: parent.hov ? bgHover : bgSecondary
                    border.color: parent.hov ? "#444444" : borderMain
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {

                        width: 3

                        height: parent.height * 0.4

                        anchors.left: parent.left

                        anchors.verticalCenter: parent.verticalCenter

                        color: accent

                        radius: 1.5

                        opacity: parent.hov ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: t("settings_pwd_title") || "Ana Parolayı Değiştir"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text { text: "Kasayı açmak için kullandığınız ana şifreyi güvenle yenileyin"; color: textMuted; font.pixelSize: 12 }
                        }

                        SettingsButton {
                            text: t("settings_pwd_btn") || "Değiştir..."
                            onClicked: changeMasterPwdDialog.open()
                        }
                    }
                }

                // Otomatik Kilit
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    color: parent.hov ? bgHover : bgSecondary
                    border.color: parent.hov ? "#444444" : borderMain
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {

                        width: 3

                        height: parent.height * 0.4

                        anchors.left: parent.left

                        anchors.verticalCenter: parent.verticalCenter

                        color: accent

                        radius: 1.5

                        opacity: parent.hov ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: t("settings_autolock_title") || "Otomatik Kilit"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text { text: "Hareketsizlik halinde kasanın otomatik kilitlenme süresi"; color: textMuted; font.pixelSize: 12 }
                        }

                        ComboBox {
                            id: lockTimeCombo
                            Layout.preferredWidth: 140
                            model: ["1 Dakika", "5 Dakika", "15 Dakika", "30 Dakika", "Devre Dışı"]
                            currentIndex: {
                                var m = vaultManager.getAutoLockMinutes()
                                if (m === 1) return 0
                                if (m === 5) return 1
                                if (m === 15) return 2
                                if (m === 30) return 3
                                return 4
                            }
                            onActivated: {
                                var mins = [1, 5, 15, 30, 0][index]
                                vaultManager.setAutoLockMinutes(mins)
                                showToast("Otomatik kilit süresi güncellendi.")
                            }
                        }
                    }

                }


                // Kendini İmha (Yanlış Şifre)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    color: parent.hov ? bgHover : bgSecondary
                    border.color: parent.hov ? danger : borderMain
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {
                        width: 3
                        height: parent.height * 0.4
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: danger
                        radius: 1.5
                        opacity: parent.hov ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Kasa İmha (Self-Destruct)"; color: parent.parent.parent.hov ? danger : textMain; font.pixelSize: 14; font.bold: true; Behavior on color { ColorAnimation { duration: 200 } } }
                            Text { text: "Art arda yanlış şifre girildiğinde tüm veritabanını kalıcı olarak siler"; color: textMuted; font.pixelSize: 12 }
                        }

                        ComboBox {
                            id: destructCombo
                            Layout.preferredWidth: 140
                            model: ["5 Hata", "10 Hata", "20 Hata", "Devre Dışı"]
                            currentIndex: {
                                var a = vaultManager.getSelfDestructAttempts()
                                if (a === 5) return 0
                                if (a === 10) return 1
                                if (a === 20) return 2
                                return 3
                            }
                            onActivated: {
                                var att = [5, 10, 20, 0][index]
                                vaultManager.setSelfDestructAttempts(att)
                                showToast(att > 0 ? (att + " hatalı girişte kasa imha edilecek.") : "Kasa imhası devre dışı bırakıldı.")
                            }
                        }
                    }
                }

                // Sızıntı Taraması (HIBP) - manuel, sonuçlar yerel veritabanında saklanır
                Rectangle {
                    id: leakScanCard
                    property bool scanning: vaultManager.isLeakScanning()
                    property int scanDone: 0
                    property int scanTotal: 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 88
                    color: bgSecondary
                    property bool hov: false
                    border.color: hov ? "#3a3a3a" : borderMain
                    radius: 8
                    HoverHandler { onHoveredChanged: parent.hov = hovered }

                    Connections {
                        target: vaultManager
                        function onLeakScanProgress(cur, total) { leakScanCard.scanDone = cur; leakScanCard.scanTotal = total }
                        function onLeakScanFinished(count) {
                            leakScanCard.scanning = false
                            loadData()
                            showToast(count > 0 ? (count + " parola veri sızıntılarında bulundu!") : "Sızıntı bulunamadı, kasanız temiz.")
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Kasayı Sızıntılara Karşı Tara"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text {
                                text: leakScanCard.scanning
                                      ? ("Taranıyor... " + leakScanCard.scanDone + " / " + leakScanCard.scanTotal)
                                      : "Have I Been Pwned (k-anonymity) ile kontrol eder; sonuçlar yerelde saklanır."
                                color: textMuted; font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        SettingsButton {
                            text: leakScanCard.scanning ? "Taranıyor..." : "Şimdi Tara"
                            enabled: !leakScanCard.scanning
                            onClicked: {
                                leakScanCard.scanning = true
                                leakScanCard.scanDone = 0
                                vaultManager.scanVaultForLeaks()
                            }
                        }
                    }
                }

                // Tarayıcı Eklentisi (Otomatik Doldurma)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: parent.hov ? bgHover : bgSecondary
                    border.color: parent.hov ? "#444444" : borderMain
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text { text: "Tarayıcı Eklentisi (Otomatik Doldurma)"; color: textMain; font.pixelSize: 14; font.bold: true }
                                Text {
                                    text: "Chrome/Edge/Firefox eklentisi yalnızca 127.0.0.1 üzerinden, token ile konuşur. Kasa kilitliyken çalışmaz."
                                    color: textMuted; font.pixelSize: 12
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                            Switch {
                                checked: vaultManager.isBrowserHostRunning()
                                onToggled: vaultManager.toggleBrowserHost(checked)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text { text: "Token:"; color: textMuted; font.pixelSize: 12 }
                            TextField {
                                id: browserTokenField
                                Layout.fillWidth: true
                                readOnly: true
                                text: vaultManager.getBrowserToken()
                                color: textMain
                                font.family: "Monospace"
                                font.pixelSize: 11
                                background: Rectangle { color: "#141414"; radius: 6; border.color: borderMain }
                            }
                            SettingsButton {
                                text: "Kopyala"
                                onClicked: { vaultManager.copyToClipboard(browserTokenField.text) }
                            }
                        }
                        Text {
                            text: "Eklenti klasörü: " + vaultManager.getBrowserExtensionPath()
                            color: textMuted; font.pixelSize: 11
                            wrapMode: Text.WrapAnywhere
                            Layout.fillWidth: true
                        }
                    }
                }

                // Acil Durum Kurtarma Kiti (Emergency Kit)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: parent.hov ? "#0f2547" : "#0a192f"
                    border.color: parent.hov ? "#0284c7" : "#0284c7"
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {

                        width: 3

                        height: parent.height * 0.4

                        anchors.left: parent.left

                        anchors.verticalCenter: parent.verticalCenter

                        color: accent

                        radius: 1.5

                        opacity: parent.hov ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "CSV İçe Aktar (Import)"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text { text: "Chrome, Firefox, Bitwarden veya VoidPass CSV dosyalarındaki şifreleri içeri aktarın"; color: textMuted; font.pixelSize: 12 }
                        }

                        SettingsButton {
                            text: "CSV Seç..."
                            onClicked: importCsvFileDialog.open()
                        }
                    }
                }

                // CSV Dışa Aktar (Export)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    color: parent.hov ? bgHover : bgSecondary
                    border.color: parent.hov ? "#444444" : borderMain
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {

                        width: 3

                        height: parent.height * 0.4

                        anchors.left: parent.left

                        anchors.verticalCenter: parent.verticalCenter

                        color: accent

                        radius: 1.5

                        opacity: parent.hov ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: t("settings_csv_title") || "CSV Olarak Dışa Aktar"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text { text: "Tüm kasanızı şifresiz Excel uyumlu CSV formatında kaydedin"; color: textMuted; font.pixelSize: 12 }
                        }

                        SettingsButton {
                            text: t("settings_csv_btn") || "Dışa Aktar..."
                            onClicked: exportCsvDialog.open()
                        }
                    }
                }

                // Şifreli .vault Yedeği
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    color: parent.hov ? bgHover : bgSecondary
                    border.color: parent.hov ? "#444444" : borderMain
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {

                        width: 3

                        height: parent.height * 0.4

                        anchors.left: parent.left

                        anchors.verticalCenter: parent.verticalCenter

                        color: accent

                        radius: 1.5

                        opacity: parent.hov ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: t("settings_backup_title") || "Şifreli Yedek (.vault)"; color: textMain; font.pixelSize: 14; font.bold: true }
                            Text { text: "AES-256 ile korunan şifreli yedek oluşturun veya geri yükleyin"; color: textMuted; font.pixelSize: 12 }
                        }

                        RowLayout {
                            spacing: 8
                            SettingsButton {
                                text: "Geri Yükle..."
                                onClicked: importVaultDialog.open()
                            }
                            SettingsButton {
                                text: "Yedek Al..."
                                onClicked: exportVaultDialog.open()
                            }
                        }
                    }
                }

                // ========================================================
                // 4. BÖLÜM: TEHLİKELİ BÖLGE
                // ========================================================
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 12
                    spacing: 8
                    Rectangle { width: 3; height: 12; radius: 1.5; color: danger }
                    Text { text: t("settings_cat_danger") || "TEHLİKELİ BÖLGE"; color: danger; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.5 }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#222222" }
                }

                // Kasa Sıfırlama
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    color: parent.hov ? "#2a1212" : "#1a0b0b"
                    border.color: parent.hov ? danger : "#3f1414"
                    border.width: 1
                    radius: 10
                    property bool hov: false
                    HoverHandler { onHoveredChanged: parent.hov = hovered }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Rectangle {

                        width: 3

                        height: parent.height * 0.4

                        anchors.left: parent.left

                        anchors.verticalCenter: parent.verticalCenter

                        color: accent

                        radius: 1.5

                        opacity: parent.hov ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: t("settings_wipe_title") || "Kasayı Tamamen Sıfırla"; color: danger; font.pixelSize: 14; font.bold: true }
                            Text { text: "Tüm kayıtları ve veritabanını kalıcı ve geri alınamaz şekilde siler"; color: textMuted; font.pixelSize: 12 }
                        }

                        SettingsButton {
                            text: t("settings_wipe_btn") || "Kasayı Sıfırla..."
                            background: Rectangle { color: parent.hovered ? "#b91c1c" : danger; radius: 6 }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; font.pixelSize: 12 }
                            onClicked: wipeDialog.open()
                        }
                    }
                }

                Item { Layout.preferredHeight: 40 }
            }
        }
    }
}
