import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

ApplicationWindow {
    visible: true
    width: 900
    height: 600
    title: "Secure Vault"
    color: bgMain

    readonly property color bgMain: "#000000"
    readonly property color bgSecondary: wallpaperPath !== "" ? "#d90a0a0a" : "#0a0a0a"
    readonly property color bgHover: wallpaperPath !== "" ? "#e6171717" : "#171717"
    readonly property color borderMain: "#262626"
    readonly property color accent: "#ffffff"
    readonly property color accentHover: "#e5e5e5"
    readonly property color textMain: "#ffffff"
    readonly property color textMuted: "#888888"
    readonly property color danger: "#ff4444"
    
    property int appState: vaultManager.isSetupRequired() ? 0 : 1
    property string wallpaperPath: vaultManager.getWallpaper()
    property real wallpaperOpacity: vaultManager.getWallpaperOpacity()
    
    // Parola Sağlığı Paneli Durumu
    property int healthScore: 100
    property int totalCount: 0
    property int weakCount: 0
    property int reusedCount: 0
    property int pwnedCount: 0
    property string healthFilter: "all"
    
    Image {
        anchors.fill: parent
        source: wallpaperPath
        fillMode: Image.PreserveAspectCrop
        opacity: wallpaperOpacity
        visible: wallpaperPath !== ""
        z: -2
    }
    
    // Metinlerin (özellikle başlıkların) her zaman okunabilmesi için estetik karartma (Vignette Filtresi)
    Rectangle {
        anchors.fill: parent
        visible: wallpaperPath !== "" // Sadece duvar kağıdı varken çalışır
        z: -1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#d9000000" } // %85 Siyah (Üstteki "Kasa" başlığı için)
            GradientStop { position: 0.2; color: "#66000000" } // %40 Siyah
            GradientStop { position: 0.8; color: "#4d000000" } // %30 Siyah
            GradientStop { position: 1.0; color: "#99000000" } // %60 Siyah (En alttaki butonlar için)
        }
    }
    
    FileDialog {
        id: wallpaperDialog
        title: "Arka Plan Seç"
        nameFilters: ["Resim Dosyaları (*.png *.jpg *.jpeg)"]
        onAccepted: {
            wallpaperPath = selectedFile
            vaultManager.setWallpaper(selectedFile)
        }
    }

    FileDialog {
        id: exportCsvDialog
        title: "Şifreleri Dışa Aktar (CSV)"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "csv"
        nameFilters: ["CSV Dosyaları (*.csv)"]
        onAccepted: {
            if (vaultManager.exportToCSV(selectedFile)) {
                showToast("Tüm şifreler başarıyla CSV dosyasına aktarıldı.")
            } else {
                showToast("Dışa aktarma işlemi başarısız oldu!")
            }
        }
    }

    Connections {
        target: vaultManager
        function onPwnedStatus(id, isPwned) {
            var count = 0
            for(var i = 0; i < vaultModel.count; i++) {
                if (vaultModel.get(i).id === id) {
                    vaultModel.setProperty(i, "isPwned", isPwned)
                }
                if (vaultModel.get(i).isPwned) count++
            }
            pwnedCount = count
        }
        function onClipboardCopied(seconds) {
            showToast("Parola kopyalandı • " + seconds + " sn sonra panodan otomatik silinecek")
        }
        function onClipboardCleared() {
            showToast("Pano güvenliğiniz için otomatik temizlendi.")
        }
        function onVaultLocked() {
            addDialog.close()
            editDialog.close()
            changeMasterPwdDialog.close()
            exportCsvDialog.close()
            vaultModel.clear()
            appState = 1
            showToast("Hareketsizlik nedeniyle kasa otomatik kilitlendi.")
        }
    }

    // Setup Page
    Item {
        anchors.fill: parent
        visible: appState === 0
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 24
            
            Image {
                source: "qrc:/icons/shield.svg"
                Layout.alignment: Qt.AlignHCenter
                sourceSize: Qt.size(48, 48)
            }
            
            Text {
                text: "Secure Vault"
                color: textMain
                font.pixelSize: 24
                font.bold: true
                font.letterSpacing: 1
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Kasanı oluşturmak için ana bir parola belirle."
                color: textMuted
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 16
            }
            
            TextField {
                id: setupPwd
                placeholderText: "Güçlü bir ana parola..."
                echoMode: TextInput.Password
                Layout.preferredWidth: 320
                Layout.preferredHeight: 48
                color: textMain
                font.pixelSize: 15
                background: Rectangle {
                    color: "transparent"
                    radius: 4
                    border.color: setupPwd.activeFocus ? accent : borderMain
                    border.width: setupPwd.activeFocus ? 2 : 1
                }
                leftPadding: 16
            }
            
            Button {
                text: "Vault'u Kur"
                Layout.preferredWidth: 320
                Layout.preferredHeight: 48
                contentItem: Text {
                    text: parent.text
                    color: bgMain
                    font.bold: true
                    font.pixelSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.down ? "#cccccc" : (parent.hovered ? accentHover : accent)
                    radius: 4
                }
                onClicked: {
                    if (vaultManager.setupVault(setupPwd.text)) {
                        appState = 2
                        loadData()
                    }
                }
            }
        }
    }
    
    // Locked Page
    Item {
        anchors.fill: parent
        visible: appState === 1
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 24
            
            Image {
                source: "qrc:/icons/lock.svg"
                Layout.alignment: Qt.AlignHCenter
                sourceSize: Qt.size(48, 48)
            }
            
            Text {
                text: "Kasa Kilitli"
                color: textMain
                font.pixelSize: 24
                font.bold: true
                font.letterSpacing: 1
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Devam etmek için ana parolanızı girin."
                color: textMuted
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 16
            }
            
            TextField {
                id: unlockPwd
                placeholderText: "Ana parola..."
                echoMode: TextInput.Password
                Layout.preferredWidth: 320
                Layout.preferredHeight: 48
                color: textMain
                font.pixelSize: 15
                background: Rectangle {
                    color: "transparent"
                    radius: 4
                    border.color: unlockPwd.activeFocus ? accent : borderMain
                    border.width: unlockPwd.activeFocus ? 2 : 1
                }
                leftPadding: 16
                onAccepted: unlockBtn.clicked()
            }
            
            Button {
                id: unlockBtn
                text: "Kilidi Aç"
                Layout.preferredWidth: 320
                Layout.preferredHeight: 48
                contentItem: Text {
                    text: parent.text
                    color: bgMain
                    font.bold: true
                    font.pixelSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.down ? "#cccccc" : (parent.hovered ? accentHover : accent)
                    radius: 4
                }
                onClicked: {
                    if (vaultManager.unlockVault(unlockPwd.text)) {
                        unlockPwd.text = ""
                        appState = 2
                        loadData()
                    } else {
                        unlockPwd.text = ""
                        unlockPwd.placeholderText = "Hatalı parola! Tekrar dene."
                    }
                }
            }
        }
    }
    
    // Dashboard Page
    Item {
        anchors.fill: parent
        visible: appState === 2
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 32
            
            // Top Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Image {
                    source: "qrc:/icons/shield.svg"
                    sourceSize: Qt.size(28, 28)
                    Layout.alignment: Qt.AlignVCenter
                }
                
                Text {
                    text: "Parolalarım"
                    color: textMain
                    font.pixelSize: 22
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.alignment: Qt.AlignVCenter
                }
                
                Item { Layout.fillWidth: true }
                
                TextField {
                    id: searchInput
                    placeholderText: "Ara..."
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    verticalAlignment: TextInput.AlignVCenter
                    color: textMain
                    background: Rectangle {
                        color: "transparent"
                        radius: 4
                        border.color: searchInput.activeFocus ? accent : borderMain
                    }
                    leftPadding: 16
                    onTextChanged: loadData()
                }
                
                ComboBox {
                    id: sortCombo
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    model: ["Yeniden Eskiye", "Eskiden Yeniye", "İsim (A-Z)", "İsim (Z-A)"]
                    
                    background: Rectangle {
                        color: "transparent"
                        radius: 4
                        border.color: sortCombo.down ? accent : borderMain
                    }
                    contentItem: Text {
                        text: sortCombo.displayText
                        color: textMain
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 16
                    }
                    
                    delegate: ItemDelegate {
                        width: sortCombo.width
                        contentItem: Text {
                            text: modelData
                            color: textMain
                            font.pixelSize: 14
                        }
                        background: Rectangle {
                            color: hovered ? bgHover : bgSecondary
                        }
                    }
                    
                    popup: Popup {
                        y: sortCombo.height - 1
                        width: sortCombo.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: sortCombo.popup.visible ? sortCombo.delegateModel : null
                            currentIndex: sortCombo.highlightedIndex
                        }
                        background: Rectangle {
                            color: bgSecondary
                            border.color: borderMain
                            radius: 4
                        }
                    }
                    
                    onActivated: loadData()
                }
                
                Button {
                    text: "Yeni Şifre"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 130
                    Layout.alignment: Qt.AlignVCenter
                    contentItem: Item {
                        anchors.fill: parent
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Image {
                                source: "qrc:/icons/plus.svg"
                                sourceSize: Qt.size(16, 16)
                            }
                            Text {
                                text: "Yeni Şifre"
                                color: bgMain
                                font.bold: true
                                font.pixelSize: 14
                            }
                        }
                    }
                    background: Rectangle {
                        color: parent.down ? "#cccccc" : (parent.hovered ? accentHover : accent)
                        radius: 4
                    }
                    onClicked: addDialog.open()
                }
            }
            
            // Parola Sağlığı Paneli (Health Dashboard Bar)
            Rectangle {
                Layout.fillWidth: true
                height: 52
                color: wallpaperPath !== "" ? "#d90c0c0c" : "#0d0d0d"
                border.color: borderMain
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 20
                    
                    // 1. Genel Güvenlik Skoru
                    RowLayout {
                        spacing: 10
                        Layout.alignment: Qt.AlignVCenter
                        
                        Rectangle {
                            width: 30; height: 30; radius: 15
                            color: healthScore >= 80 ? "#1a10b981" : (healthScore >= 50 ? "#1afbbf24" : "#1aff4444")
                            border.color: healthScore >= 80 ? "#10b981" : (healthScore >= 50 ? "#fbbf24" : danger)
                            border.width: 1.5
                            Text {
                                anchors.centerIn: parent
                                text: healthScore
                                color: healthScore >= 80 ? "#10b981" : (healthScore >= 50 ? "#fbbf24" : danger)
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 1
                            Text { 
                                text: "Kasa Sağlığı: %" + healthScore
                                color: textMain
                                font.pixelSize: 13
                                font.bold: true 
                            }
                            Text { 
                                text: healthScore >= 85 ? "Mükemmel Koruma" : (healthScore >= 60 ? "İyileştirme Önerilir" : "Riskli Şifreler Mevcut")
                                color: healthScore >= 85 ? "#34d399" : (healthScore >= 60 ? "#fbbf24" : danger)
                                font.pixelSize: 10 
                            }
                        }
                    }
                    
                    Rectangle {
                        width: 1; height: 24; color: borderMain; Layout.alignment: Qt.AlignVCenter
                    }
                    
                    // 2. Filtre Badgeleri (Tümü, Tekrar Eden, Zayıf, Sızıntı)
                    RowLayout {
                        spacing: 8
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        
                        // Tümü
                        Rectangle {
                            height: 30
                            width: allTxt.implicitWidth + 24
                            radius: 15
                            color: healthFilter === "all" ? (wallpaperPath !== "" ? "#33ffffff" : "#222222") : "transparent"
                            border.color: healthFilter === "all" ? accent : borderMain
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { id: allTxt; text: "Tümü (" + totalCount + ")"; color: healthFilter === "all" ? textMain : textMuted; font.pixelSize: 12; font.bold: healthFilter === "all" }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { healthFilter = "all"; loadData() }
                            }
                        }
                        
                        // Tekrar Eden (Reused)
                        Rectangle {
                            height: 30
                            width: reusedTxt.implicitWidth + (reusedCount > 0 ? 28 : 22)
                            radius: 15
                            color: healthFilter === "reused" ? (wallpaperPath !== "" ? "#33ffffff" : "#222222") : (reusedCount > 0 ? "#15fbbf24" : "transparent")
                            border.color: healthFilter === "reused" ? "#fbbf24" : (reusedCount > 0 ? "#4dfbbf24" : borderMain)
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5
                                Image {
                                    source: "qrc:/icons/copy.svg"
                                    sourceSize: Qt.size(11, 11)
                                    visible: reusedCount > 0
                                }
                                Text { 
                                    id: reusedTxt
                                    text: reusedCount > 0 ? "Tekrar Eden (" + reusedCount + ")" : "Tekrar: 0"
                                    color: reusedCount > 0 ? "#fbbf24" : textMuted
                                    font.pixelSize: 12
                                    font.bold: healthFilter === "reused"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { healthFilter = healthFilter === "reused" ? "all" : "reused"; loadData() }
                            }
                        }
                        
                        // Zayıf (Weak)
                        Rectangle {
                            height: 30
                            width: weakTxt.implicitWidth + (weakCount > 0 ? 28 : 22)
                            radius: 15
                            color: healthFilter === "weak" ? (wallpaperPath !== "" ? "#33ffffff" : "#222222") : (weakCount > 0 ? "#15ff4444" : "transparent")
                            border.color: healthFilter === "weak" ? danger : (weakCount > 0 ? "#4dff4444" : borderMain)
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5
                                Image {
                                    source: "qrc:/icons/alert.svg"
                                    sourceSize: Qt.size(11, 11)
                                    visible: weakCount > 0
                                }
                                Text { 
                                    id: weakTxt
                                    text: weakCount > 0 ? "Zayıf (" + weakCount + ")" : "Zayıf: 0"
                                    color: weakCount > 0 ? danger : textMuted
                                    font.pixelSize: 12
                                    font.bold: healthFilter === "weak"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { healthFilter = healthFilter === "weak" ? "all" : "weak"; loadData() }
                            }
                        }
                        
                        // Sızdırılmış (Pwned)
                        Rectangle {
                            height: 30
                            width: pwnedTxt.implicitWidth + (pwnedCount > 0 ? 28 : 22)
                            radius: 15
                            color: healthFilter === "pwned" ? (wallpaperPath !== "" ? "#33ffffff" : "#222222") : (pwnedCount > 0 ? "#25ff4444" : "transparent")
                            border.color: healthFilter === "pwned" ? danger : (pwnedCount > 0 ? danger : borderMain)
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5
                                Image {
                                    source: "qrc:/icons/shield.svg"
                                    sourceSize: Qt.size(11, 11)
                                    visible: pwnedCount > 0
                                }
                                Text { 
                                    id: pwnedTxt
                                    text: pwnedCount > 0 ? "Sızıntı (" + pwnedCount + ")" : "Sızıntı: 0"
                                    color: pwnedCount > 0 ? danger : textMuted
                                    font.pixelSize: 12
                                    font.bold: healthFilter === "pwned"
                                }
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { healthFilter = healthFilter === "pwned" ? "all" : "pwned"; loadData() }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
            }
            
            // Table Header
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: borderMain
            }
            
            RowLayout {
                Layout.fillWidth: true
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 0
                Text { text: "SERVİS"; color: textMuted; font.bold: true; font.pixelSize: 11; font.letterSpacing: 1; Layout.preferredWidth: 200; verticalAlignment: Text.AlignVCenter }
                Text { text: "KULLANICI ADI"; color: textMuted; font.bold: true; font.pixelSize: 11; font.letterSpacing: 1; Layout.preferredWidth: 260; verticalAlignment: Text.AlignVCenter }
                Text { text: "PAROLA"; color: textMuted; font.bold: true; font.pixelSize: 11; font.letterSpacing: 1; Layout.fillWidth: true; verticalAlignment: Text.AlignVCenter }
                Item { Layout.preferredWidth: 176 }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: borderMain
                Layout.bottomMargin: 8
            }
            
            // List View
            ListView {
                id: passwordList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                
                model: ListModel { id: vaultModel }
                
                delegate: Rectangle {
                    width: passwordList.width
                    height: 56
                    color: ma.hovered ? bgHover : (wallpaperPath !== "" ? "#66000000" : "transparent")
                    radius: 6
                    
                    property bool showPassword: false
                    
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 0
                        
                        Text { text: model.service ? model.service : "Bilinmiyor (Eski)"; color: textMain; font.pixelSize: 14; font.bold: true; Layout.preferredWidth: 200; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter }
                        Text { text: model.username; color: textMuted; font.pixelSize: 14; Layout.preferredWidth: 260; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text { text: showPassword ? model.password : "••••••••••••"; color: textMuted; font.pixelSize: 14; font.letterSpacing: showPassword ? 0 : 2; verticalAlignment: Text.AlignVCenter }
                            
                            // Tekrar Eden Şifre Rozeti
                            Rectangle {
                                visible: model.isReused !== undefined ? model.isReused : false
                                width: 20; height: 20; radius: 4
                                color: "#22fbbf24"
                                border.color: "#fbbf24"
                                border.width: 1
                                Image {
                                    source: "qrc:/icons/copy.svg"
                                    sourceSize: Qt.size(11, 11)
                                    anchors.centerIn: parent
                                }
                                ToolTip.visible: reusedHover.containsMouse
                                ToolTip.text: "UYARI: Bu şifre birden fazla hesapta kullanılmış!"
                                MouseArea { id: reusedHover; anchors.fill: parent; hoverEnabled: true }
                            }
                            
                            // Zayıf Şifre Rozeti
                            Rectangle {
                                visible: model.isWeak !== undefined ? model.isWeak : false
                                width: 20; height: 20; radius: 4
                                color: "#22ff4444"
                                border.color: danger
                                border.width: 1
                                Image {
                                    source: "qrc:/icons/alert.svg"
                                    sourceSize: Qt.size(11, 11)
                                    anchors.centerIn: parent
                                }
                                ToolTip.visible: weakHover.containsMouse
                                ToolTip.text: "UYARI: Bu şifre zayıf veya kolay tahmin edilebilir!"
                                MouseArea { id: weakHover; anchors.fill: parent; hoverEnabled: true }
                            }
                            
                            // Sızıntı Rozeti
                            Image {
                                source: "qrc:/icons/alert.svg"
                                sourceSize: Qt.size(16, 16)
                                visible: model.isPwned !== undefined ? model.isPwned : false
                                ToolTip.visible: hoverArea.containsMouse
                                ToolTip.text: "KRİTİK UYARI: Bu şifre daha önce veri sızıntılarında (HIBP) açığa çıkmış!"
                                MouseArea { id: hoverArea; anchors.fill: parent; hoverEnabled: true }
                            }
                            Item { Layout.fillWidth: true }
                        }
                        
                        RowLayout {
                            Layout.preferredWidth: 176
                            spacing: 12
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            
                            Button {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                icon.source: showPassword ? "qrc:/icons/eye-off.svg" : "qrc:/icons/eye.svg"
                                icon.color: hovered ? "#000000" : textMain
                                icon.width: 16
                                icon.height: 16
                                display: AbstractButton.IconOnly
                                ToolTip.visible: hovered
                                ToolTip.text: showPassword ? "Gizle" : "Göster"
                                background: Rectangle { 
                                    color: parent.hovered ? textMain : "transparent"
                                    radius: 4 
                                }
                                onClicked: showPassword = !showPassword
                            }
                            
                            Button {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                icon.source: "qrc:/icons/copy.svg"
                                icon.color: hovered ? "#000000" : textMain
                                icon.width: 16
                                icon.height: 16
                                display: AbstractButton.IconOnly
                                ToolTip.visible: hovered
                                ToolTip.text: "Kopyala (30s sonra silinir)"
                                background: Rectangle { 
                                    color: parent.hovered ? textMain : "transparent"
                                    radius: 4 
                                }
                                onClicked: vaultManager.copyToClipboard(model.password)
                            }
                            
                            Button {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                icon.source: "qrc:/icons/edit.svg"
                                icon.color: hovered ? "#000000" : textMain
                                icon.width: 16
                                icon.height: 16
                                display: AbstractButton.IconOnly
                                ToolTip.visible: hovered
                                ToolTip.text: "Düzenle"
                                background: Rectangle { 
                                    color: parent.hovered ? textMain : "transparent"
                                    radius: 4 
                                }
                                onClicked: {
                                    editDialog.entryId = model.id
                                    editDialog.serviceText = model.service
                                    editDialog.usernameText = model.username
                                    editDialog.passwordText = model.password
                                    editDialog.open()
                                }
                            }
                            
                            Button {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                icon.source: "qrc:/icons/trash.svg"
                                icon.color: hovered ? "#ffffff" : danger
                                icon.width: 16
                                icon.height: 16
                                display: AbstractButton.IconOnly
                                ToolTip.visible: hovered
                                ToolTip.text: "Sil"
                                background: Rectangle { 
                                    color: parent.hovered ? danger : "transparent"
                                    radius: 4 
                                }
                                onClicked: {
                                    vaultManager.deleteEntry(model.id)
                                    loadData()
                                    showToast("Şifre silindi.")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Settings Button (Bottom Right)
        Button {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 40
            width: 48
            height: 48
            icon.source: "qrc:/icons/settings.svg"
            icon.color: hovered ? "#000000" : textMuted
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            background: Rectangle {
                color: parent.hovered ? textMain : bgSecondary
                radius: 24
                border.color: borderMain
            }
            onClicked: appState = 3
        }
    }
    
    // Settings Fullscreen Page
    Item {
        anchors.fill: parent
        visible: appState === 3
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 32
            
            // Top Bar with Back Button
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Button {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    icon.source: "qrc:/icons/back.svg"
                    icon.color: hovered ? "#000000" : textMain
                    icon.width: 24
                    icon.height: 24
                    display: AbstractButton.IconOnly
                    background: Rectangle {
                        color: parent.hovered ? textMain : "transparent"
                        radius: 22
                        border.color: borderMain
                    }
                    onClicked: appState = 2
                }
                
                Text {
                    text: "Ayarlar"
                    color: textMain
                    font.pixelSize: 22
                    font.bold: true
                    font.letterSpacing: 1
                }
                
                Item { Layout.fillWidth: true }
            }
            
            // Settings List
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 16
                
                // 1. Anti-Screenshot Toggle
                Rectangle {
                    Layout.fillWidth: true
                    height: 72
                    color: "transparent"
                    border.color: borderMain
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        Rectangle {
                            width: 40; height: 40; radius: 8; color: bgSecondary
                            Image { source: "qrc:/icons/shield.svg"; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Ekran Görüntüsü Koruması"; color: textMain; font.pixelSize: 15; font.bold: true }
                            Text { text: "OBS ve ekran alıntı araçlarını (Snipping Tool) engeller."; color: textMuted; font.pixelSize: 13 }
                        }
                        
                        Switch {
                            id: screenshotSwitch
                            checked: true
                            onCheckedChanged: vaultManager.setScreenshotProtection(checked)
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 26
                                radius: 13
                                color: screenshotSwitch.checked ? accent : bgSecondary
                                border.color: screenshotSwitch.checked ? accent : borderMain
                                
                                Rectangle {
                                    x: screenshotSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: textMain
                                    Behavior on x { NumberAnimation { duration: 200 } }
                                }
                            }
                        }
                    }
                }
                
                // 2. Auto Lock
                Rectangle {
                    Layout.fillWidth: true
                    height: 72
                    color: "transparent"
                    border.color: borderMain
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        Rectangle {
                            width: 40; height: 40; radius: 8; color: bgSecondary
                            Image { source: "qrc:/icons/clock.svg"; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Otomatik Kilit"; color: textMain; font.pixelSize: 15; font.bold: true }
                            Text { text: "Belirli bir süre boşta kalınca kasayı otomatik kilitler."; color: textMuted; font.pixelSize: 13 }
                        }
                        
                        ComboBox {
                            id: autoLockCombo
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 36
                            model: ["1 Dakika", "5 Dakika", "10 Dakika", "Hiçbir Zaman"]
                            
                            function minutesToIndex(mins) {
                                if (mins === 1) return 0;
                                if (mins === 5) return 1;
                                if (mins === 10) return 2;
                                return 3;
                            }
                            function indexToMinutes(idx) {
                                if (idx === 0) return 1;
                                if (idx === 1) return 5;
                                if (idx === 2) return 10;
                                return 0;
                            }
                            
                            currentIndex: minutesToIndex(vaultManager.getAutoLockMinutes())
                            
                            onActivated: {
                                var mins = indexToMinutes(currentIndex)
                                vaultManager.setAutoLockMinutes(mins)
                                if (mins > 0) {
                                    showToast("Otomatik kilit " + mins + " dakika olarak ayarlandı.")
                                } else {
                                    showToast("Otomatik kilit devre dışı bırakıldı.")
                                }
                            }
                            
                            background: Rectangle {
                                color: bgSecondary
                                radius: 6
                                border.color: borderMain
                            }
                            contentItem: Text {
                                text: autoLockCombo.displayText
                                color: textMain
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 12
                            }
                            delegate: ItemDelegate {
                                width: autoLockCombo.width
                                contentItem: Text { text: modelData; color: textMain; font.pixelSize: 13 }
                                background: Rectangle { color: hovered ? bgHover : bgSecondary }
                            }
                        }
                    }
                }
                
                // 3. Export CSV
                Rectangle {
                    Layout.fillWidth: true
                    height: 72
                    color: "transparent"
                    border.color: borderMain
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        Rectangle {
                            width: 40; height: 40; radius: 8; color: bgSecondary
                            Image { source: "qrc:/icons/download.svg"; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Dışa Aktar (CSV)"; color: textMain; font.pixelSize: 15; font.bold: true }
                            Text { text: "Tüm şifreleri Excel uyumlu CSV formatında dışa aktarır."; color: textMuted; font.pixelSize: 13 }
                        }
                        
                        Button {
                            text: "Dışa Aktar"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            background: Rectangle { color: parent.hovered ? bgHover : bgSecondary; radius: 6; border.color: borderMain }
                            contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: exportCsvDialog.open()
                        }
                    }
                }
                
                // 4. Ana Parolayı Değiştir
                Rectangle {
                    Layout.fillWidth: true
                    height: 72
                    color: "transparent"
                    border.color: borderMain
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        Rectangle {
                            width: 40; height: 40; radius: 8; color: bgSecondary
                            Image { source: "qrc:/icons/key.svg"; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Ana Parolayı Değiştir"; color: textMain; font.pixelSize: 15; font.bold: true }
                            Text { text: "Kasa anahtarını günceller ve tüm kayıtları arka planda yeniden şifreler."; color: textMuted; font.pixelSize: 13 }
                        }
                        
                        Button {
                            text: "Değiştir"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            background: Rectangle { color: parent.hovered ? bgHover : bgSecondary; radius: 6; border.color: borderMain }
                            contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: changeMasterPwdDialog.open()
                        }
                    }
                }
                
                // 5. Wipe Vault
                Rectangle {
                    Layout.fillWidth: true
                    height: 72
                    color: "transparent"
                    border.color: danger
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        Rectangle {
                            width: 40; height: 40; radius: 8; color: "#22ff4444"
                            Image { source: "qrc:/icons/trash.svg"; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Kasayı Sıfırla"; color: danger; font.pixelSize: 15; font.bold: true }
                            Text { text: "Tüm veritabanını kalıcı olarak siler. Geri alınamaz."; color: textMuted; font.pixelSize: 13 }
                        }
                        
                        Button {
                            text: "SİL"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 36
                            background: Rectangle { color: danger; radius: 6 }
                            contentItem: Text { text: parent.text; color: bgMain; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                vaultManager.wipeVault()
                                vaultModel.clear()
                                appState = 0
                            }
                        }
                    }
                }
                
                // 5. Wallpaper
                Rectangle {
                    Layout.fillWidth: true
                    height: wallpaperPath !== "" ? 100 : 72
                    color: "transparent"
                    border.color: borderMain
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        Rectangle {
                            width: 40; height: 40; radius: 8; color: bgSecondary
                            Image { source: "qrc:/icons/image.svg"; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Arka Plan Görseli"; color: textMain; font.pixelSize: 15; font.bold: true }
                            Text { text: wallpaperPath !== "" ? "Opaklık: %" + Math.round(wallpaperOpacity * 100) : "Arka planda estetik duracak bir görsel seçin."; color: textMuted; font.pixelSize: 13 }
                            
                            Slider {
                                visible: wallpaperPath !== ""
                                Layout.fillWidth: true
                                Layout.preferredHeight: 16
                                from: 0.01
                                to: 1.0
                                value: wallpaperOpacity
                                onValueChanged: {
                                    wallpaperOpacity = value
                                    vaultManager.setWallpaperOpacity(value)
                                }
                                
                                background: Rectangle {
                                    x: parent.leftPadding
                                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                    width: parent.availableWidth
                                    height: 4
                                    radius: 2
                                    color: borderMain
                                    
                                    Rectangle {
                                        width: parent.parent.visualPosition * parent.width
                                        height: parent.height
                                        color: accent
                                        radius: 2
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: parent.pressed ? "#f0f0f0" : textMain
                                }
                            }
                        }
                        
                        Button {
                            text: wallpaperPath === "" ? "Seç" : "Değiştir"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 36
                            background: Rectangle { color: parent.hovered ? bgHover : bgSecondary; radius: 6; border.color: borderMain }
                            contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: wallpaperDialog.open()
                        }
                        
                        Button {
                            visible: wallpaperPath !== ""
                            text: "Kaldır"
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 36
                            background: Rectangle { color: danger; radius: 6 }
                            contentItem: Text { text: parent.text; color: bgMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                wallpaperPath = ""
                                vaultManager.setWallpaper("")
                            }
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
        }
    }
    
    // Add Dialog
    Dialog {
        id: addDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 440
        parent: Overlay.overlay
        modal: true
        
        background: Rectangle {
            color: bgSecondary
            radius: 8
            border.color: borderMain
            border.width: 1
        }
        
        contentItem: ColumnLayout {
            spacing: 24
            
            Text {
                text: "Yeni Şifre Ekle"
                color: textMain
                font.pixelSize: 18
                font.bold: true
            }
            
            TextField {
                id: addService
                placeholderText: "Servis adı (Örn: GitHub)"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: textMain
                background: Rectangle { color: "transparent"; radius: 4; border.color: addService.activeFocus ? accent : borderMain }
                leftPadding: 12
            }
            
            TextField {
                id: addUsername
                placeholderText: "Kullanıcı Adı veya E-posta"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: textMain
                background: Rectangle { color: "transparent"; radius: 4; border.color: addUsername.activeFocus ? accent : borderMain }
                leftPadding: 12
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    TextField {
                        id: addPassword
                        placeholderText: "Parola"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        color: textMain
                        background: Rectangle { color: "transparent"; radius: 4; border.color: addPassword.activeFocus ? accent : borderMain }
                        leftPadding: 12
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: borderMain
                        visible: addPassword.text.length > 0
                        Rectangle {
                            height: parent.height
                            radius: 2
                            Behavior on width { NumberAnimation { duration: 200 } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                            property int score: addPassword.text.length > 0 ? vaultManager.checkPasswordStrength(addPassword.text) : 0
                            width: parent.width * (score + 1) / 5
                            color: score <= 1 ? danger : (score <= 2 ? "#fbbf24" : (score <= 3 ? "#34d399" : "#10b981"))
                        }
                    }
                }
                
                Button {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    icon.source: "qrc:/icons/dice.svg"
                    icon.color: hovered ? "#000000" : textMain
                    icon.width: 20
                    icon.height: 20
                    display: AbstractButton.IconOnly
                    background: Rectangle { 
                        color: parent.hovered ? textMain : bgHover
                        radius: 4
                    }
                    onClicked: addPassword.text = passwordGen.generate(16)
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Item { Layout.fillWidth: true }
                Button {
                    text: "İptal"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 100
                    background: Rectangle { color: "transparent"; radius: 4; border.color: borderMain; border.width: 1 }
                    contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: addDialog.close()
                }
                Button {
                    text: "Kaydet"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 100
                    background: Rectangle { color: accent; radius: 4 }
                    contentItem: Text { text: parent.text; color: bgMain; font.pixelSize: 14; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if(addService.text !== "" && addPassword.text !== "") {
                            vaultManager.addEntry(addService.text, addUsername.text, addPassword.text)
                            addService.text = ""; addUsername.text = ""; addPassword.text = ""
                            addDialog.close()
                            loadData()
                            showToast("Yeni şifre başarıyla eklendi.")
                        }
                    }
                }
            }
        }
    }
    
    // Edit Dialog
    Dialog {
        id: editDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 440
        parent: Overlay.overlay
        modal: true
        
        property int entryId: 0
        property alias serviceText: editService.text
        property alias usernameText: editUsername.text
        property alias passwordText: editPassword.text
        
        background: Rectangle {
            color: bgSecondary
            radius: 8
            border.color: borderMain
            border.width: 1
        }
        
        contentItem: ColumnLayout {
            spacing: 24
            
            Text {
                text: "Şifreyi Düzenle"
                color: textMain
                font.pixelSize: 18
                font.bold: true
            }
            
            TextField {
                id: editService
                placeholderText: "Servis adı (Örn: GitHub)"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: textMain
                background: Rectangle { color: "transparent"; radius: 4; border.color: editService.activeFocus ? accent : borderMain }
                leftPadding: 12
            }
            
            TextField {
                id: editUsername
                placeholderText: "Kullanıcı Adı veya E-posta"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: textMain
                background: Rectangle { color: "transparent"; radius: 4; border.color: editUsername.activeFocus ? accent : borderMain }
                leftPadding: 12
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    TextField {
                        id: editPassword
                        placeholderText: "Parola"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        color: textMain
                        background: Rectangle { color: "transparent"; radius: 4; border.color: editPassword.activeFocus ? accent : borderMain }
                        leftPadding: 12
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: borderMain
                        visible: editPassword.text.length > 0
                        Rectangle {
                            height: parent.height
                            radius: 2
                            Behavior on width { NumberAnimation { duration: 200 } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                            property int score: editPassword.text.length > 0 ? vaultManager.checkPasswordStrength(editPassword.text) : 0
                            width: parent.width * (score + 1) / 5
                            color: score <= 1 ? danger : (score <= 2 ? "#fbbf24" : (score <= 3 ? "#34d399" : "#10b981"))
                        }
                    }
                }
                
                Button {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    icon.source: "qrc:/icons/dice.svg"
                    icon.color: hovered ? "#000000" : textMain
                    icon.width: 20
                    icon.height: 20
                    display: AbstractButton.IconOnly
                    background: Rectangle { 
                        color: parent.hovered ? textMain : bgHover
                        radius: 4
                    }
                    onClicked: editPassword.text = passwordGen.generate(16)
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Item { Layout.fillWidth: true }
                Button {
                    text: "İptal"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 100
                    background: Rectangle { color: "transparent"; radius: 4; border.color: borderMain; border.width: 1 }
                    contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: editDialog.close()
                }
                Button {
                    text: "Güncelle"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 100
                    background: Rectangle { color: accent; radius: 4 }
                    contentItem: Text { text: parent.text; color: bgMain; font.pixelSize: 14; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if(editService.text !== "" && editPassword.text !== "") {
                            vaultManager.updateEntry(editDialog.entryId, editService.text, editUsername.text, editPassword.text)
                            editDialog.close()
                            loadData()
                            showToast("Şifre başarıyla güncellendi.")
                        }
                    }
                }
            }
        }
    }
    
    // Change Master Password Dialog
    Dialog {
        id: changeMasterPwdDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 440
        parent: Overlay.overlay
        modal: true
        
        onAboutToShow: {
            currentMasterInput.text = ""
            newMasterInput.text = ""
            confirmMasterInput.text = ""
            changePwdError.text = ""
            showNewMasterPwd = false
        }
        
        property bool showNewMasterPwd: false
        
        background: Rectangle {
            color: bgSecondary
            radius: 8
            border.color: borderMain
            border.width: 1
        }
        
        contentItem: ColumnLayout {
            spacing: 20
            
            Text {
                text: "Ana Parolayı Güncelle"
                color: textMain
                font.pixelSize: 18
                font.bold: true
            }
            
            Text {
                text: "Yeni bir ana parola belirleyin. Tüm kasanız yeni anahtarınızla anında yeniden şifrelenecektir."
                color: textMuted
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            
            TextField {
                id: currentMasterInput
                placeholderText: "Mevcut Ana Parola"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: textMain
                background: Rectangle { color: "transparent"; radius: 4; border.color: currentMasterInput.activeFocus ? accent : borderMain }
                leftPadding: 12
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    TextField {
                        id: newMasterInput
                        placeholderText: "Yeni Ana Parola (En az 8 karakter)"
                        echoMode: changeMasterPwdDialog.showNewMasterPwd ? TextInput.Normal : TextInput.Password
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        color: textMain
                        background: Rectangle { color: "transparent"; radius: 4; border.color: newMasterInput.activeFocus ? accent : borderMain }
                        leftPadding: 12
                    }
                    
                    Button {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        icon.source: changeMasterPwdDialog.showNewMasterPwd ? "qrc:/icons/eye-off.svg" : "qrc:/icons/eye.svg"
                        icon.color: hovered ? "#000000" : textMain
                        icon.width: 18
                        icon.height: 18
                        display: AbstractButton.IconOnly
                        background: Rectangle { 
                            color: parent.hovered ? textMain : bgHover
                            radius: 4
                        }
                        onClicked: changeMasterPwdDialog.showNewMasterPwd = !changeMasterPwdDialog.showNewMasterPwd
                    }
                }
                
                // Güç göstergesi
                Rectangle {
                    Layout.fillWidth: true
                    height: 4
                    radius: 2
                    color: borderMain
                    visible: newMasterInput.text.length > 0
                    Rectangle {
                        height: parent.height
                        radius: 2
                        Behavior on width { NumberAnimation { duration: 200 } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                        property int score: newMasterInput.text.length > 0 ? vaultManager.checkPasswordStrength(newMasterInput.text) : 0
                        width: parent.width * (score + 1) / 5
                        color: score <= 1 ? danger : (score <= 2 ? "#fbbf24" : (score <= 3 ? "#34d399" : "#10b981"))
                    }
                }
            }
            
            TextField {
                id: confirmMasterInput
                placeholderText: "Yeni Parola (Tekrar)"
                echoMode: changeMasterPwdDialog.showNewMasterPwd ? TextInput.Normal : TextInput.Password
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: textMain
                background: Rectangle { color: "transparent"; radius: 4; border.color: confirmMasterInput.activeFocus ? accent : borderMain }
                leftPadding: 12
            }
            
            Text {
                id: changePwdError
                color: danger
                font.pixelSize: 12
                visible: text !== ""
                Layout.fillWidth: true
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Item { Layout.fillWidth: true }
                Button {
                    text: "İptal"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 100
                    background: Rectangle { color: "transparent"; radius: 4; border.color: borderMain; border.width: 1 }
                    contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: changeMasterPwdDialog.close()
                }
                Button {
                    text: "Parolayı Güncelle"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 150
                    background: Rectangle { color: accent; radius: 4 }
                    contentItem: Text { text: parent.text; color: bgMain; font.pixelSize: 14; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (currentMasterInput.text === "") {
                            changePwdError.text = "Lütfen mevcut ana parolanızı girin."
                            return
                        }
                        if (newMasterInput.text.length < 8) {
                            changePwdError.text = "Yeni parola en az 8 karakter olmalıdır."
                            return
                        }
                        if (newMasterInput.text !== confirmMasterInput.text) {
                            changePwdError.text = "Yeni parolalar birbiriyle uyuşmuyor!"
                            return
                        }
                        
                        if (vaultManager.changeMasterPassword(currentMasterInput.text, newMasterInput.text)) {
                            changeMasterPwdDialog.close()
                            showToast("Ana parola güncellendi ve tüm kasa yeniden şifrelendi.")
                        } else {
                            changePwdError.text = "Mevcut ana parola hatalı! Lütfen kontrol edin."
                        }
                    }
                }
            }
        }
    }
    
    // Modern Glassmorphic Toast Notification
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: toastVisible ? 24 : -60
        height: 42
        width: toastTextItem.implicitWidth + 56
        radius: 21
        color: "#f2121212"
        border.color: "#333333"
        border.width: 1
        opacity: toastVisible ? 1.0 : 0.0
        z: 9999
        
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on anchors.bottomMargin { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

        property bool toastVisible: false
        property alias text: toastTextItem.text

        Timer {
            id: toastTimer
            interval: 3200
            onTriggered: toast.toastVisible = false
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 10

            Image {
                source: "qrc:/icons/shield.svg"
                sourceSize: Qt.size(16, 16)
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                id: toastTextItem
                color: "#ffffff"
                font.pixelSize: 13
                font.weight: Font.Medium
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    function showToast(message) {
        toast.text = message
        toast.toastVisible = true
        toastTimer.restart()
    }
    
    function loadData() {
        vaultModel.clear()
        
        var report = vaultManager.getSecurityReport()
        healthScore = report.healthScore !== undefined ? report.healthScore : 100
        totalCount = report.totalCount !== undefined ? report.totalCount : 0
        weakCount = report.weakCount !== undefined ? report.weakCount : 0
        reusedCount = report.reusedCount !== undefined ? report.reusedCount : 0
        
        var weakSet = report.weakIds || []
        var reusedSet = report.reusedIds || []

        var entries = vaultManager.getAllEntries()
        
        entries.sort(function(a, b) {
            if (sortCombo.currentIndex === 0) return b.id - a.id;
            if (sortCombo.currentIndex === 1) return a.id - b.id;
            if (sortCombo.currentIndex === 2) return a.service.localeCompare(b.service);
            if (sortCombo.currentIndex === 3) return b.service.localeCompare(a.service);
            return 0;
        });
        
        var q = searchInput.text.toLowerCase()
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i]
            var matchesSearch = (q === "" || entry.service.toLowerCase().indexOf(q) !== -1 || entry.username.toLowerCase().indexOf(q) !== -1)
            if (!matchesSearch) continue;

            entry.isWeak = (weakSet.indexOf(entry.id) !== -1)
            entry.isReused = (reusedSet.indexOf(entry.id) !== -1)
            entry.isPwned = false

            // Filtre kontrolü
            if (healthFilter === "weak" && !entry.isWeak) continue;
            if (healthFilter === "reused" && !entry.isReused) continue;

            vaultModel.append(entry)
            vaultManager.checkPwnedAsync(entry.id, entry.password)
        }
    }
}
