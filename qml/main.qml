import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

ApplicationWindow {
    visible: true
    width: 960
    height: 620
    minimumWidth: 780
    minimumHeight: 480
    title: "VoidPass"
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
    property real uiScale: vaultManager.getUiScale()
    property string appLang: vaultManager.getLanguage() || "tr"

    readonly property var translations: ({
        tr: {
            app_title: "VoidPass",
            welcome_title: "Hoş Geldiniz",
            welcome_subtitle: "Lütfen kullanmak istediğiniz dili seçin",
            welcome_tr_title: "Türkçe",
            welcome_tr_desc: "Türkiye • Türkçe ile devam et",
            welcome_en_title: "English",
            welcome_en_desc: "United States • Continue in English",
            
            setup_title: "Hoş Geldiniz",
            setup_desc: "Kasanızı güvenceye almak için güçlü bir ana parola belirleyin.",
            setup_pw_label: "Ana Parola",
            setup_pw_placeholder: "En az 8 karakter önerilir",
            setup_confirm_label: "Ana Parolayı Onayla",
            setup_confirm_placeholder: "Parolayı tekrar girin",
            setup_create_btn: "Kasayı Oluştur",
            
            login_title: "Kasa Kilitli",
            login_desc: "Şifrelerinize erişmek için ana parolanızı girin.",
            login_pw_label: "Ana Parola",
            login_pw_placeholder: "Ana parolanızı girin",
            login_unlock_btn: "Kasanın Kilidini Aç",
            
            search_placeholder: "Kasalarda ara... (Servis veya e-posta)",
            add_password_btn: "+ Yeni Şifre Ekle",
            
            health_score: "Güvenlik Puanı",
            health_all: "Tümü",
            health_leaked: "Sızdırılmış",
            health_weak: "Zayıf",
            health_reused: "Tekrar Eden",
            
            col_service: "SERVİS",
            col_username: "KULLANICI ADI",
            col_password: "PAROLA",
            
            tooltip_hide: "Gizle",
            tooltip_show: "Göster",
            tooltip_copy: "Kopyala (30s sonra silinir)",
            tooltip_edit: "Düzenle",
            tooltip_delete: "Sil",
            
            toast_deleted: "Şifre silindi.",
            toast_saved: "Şifre kaydedildi.",
            toast_updated: "Şifre güncellendi.",
            toast_copied: "Şifre panoya kopyalandı! (30 sn sonra silinecek)",
            toast_lang_tr: "Dil Türkçe olarak ayarlandı.",
            toast_lang_en: "Language set to English.",
            
            dialog_add_title: "Yeni Şifre Ekle",
            dialog_edit_title: "Şifreyi Düzenle",
            dialog_service_label: "Servis / Platform",
            dialog_service_placeholder: "Örn: Google, Netflix, Steam...",
            dialog_service_suggest: "Önerilen Popüler Servisler:",
            dialog_username_label: "Kullanıcı Adı veya E-Posta",
            dialog_username_placeholder: "Örn: ornek@gmail.com",
            dialog_password_label: "Parola",
            dialog_password_placeholder: "Güçlü bir parola girin",
            dialog_generate_btn: "Üret",
            dialog_cancel_btn: "İptal",
            dialog_save_btn: "Kaydet",
            dialog_update_btn: "Değişiklikleri Kaydet",
            
            settings_title: "Ayarlar",
            settings_subtitle: "Görünüm, güvenlik ve veri yönetimi tercihlerinizi yapılandırın",
            settings_back: "Geri Dön",
            settings_cat_appearance: "GÖRÜNÜM & ARAYÜZ",
            settings_cat_security: "GÜVENLİK & KORUMA",
            settings_cat_backup: "YEDEKLEME & VERİ YÖNETİMİ",
            settings_cat_danger: "TEHLİKELİ BÖLGE",
            
            settings_lang_title: "Uygulama Dili (Language)",
            settings_lang_desc: "Arayüz dilini Türkçe veya İngilizce olarak seçin.",
            
            settings_scale_title: "Arayüz Ölçeği (UI Scale)",
            settings_scale_desc: "Pencere boyutuna ve ekran çözünürlüğüne göre arayüzü ölçeklendirin.",
            settings_scale_fit: "Ekranıma Tam Uydur",
            
            settings_wallpaper_title: "Arka Plan Görseli",
            settings_wallpaper_desc: "Kasanızın arkasına özel bir duvar kağıdı ekleyin.",
            settings_wallpaper_remove: "Görseli Kaldır",
            settings_wallpaper_select: "Görsel Seç",
            settings_wallpaper_opacity: "Görsel Saydamlığı",
            
            settings_autolock_title: "Otomatik Kilit Zaman Aşımı",
            settings_autolock_desc: "Belirtilen süre boyunca işlem yapılmazsa kasa kilitlenir.",
            settings_autolock_disabled: "Devre Dışı",
            settings_autolock_mins: "Dakika",
            
            settings_screenprotect_title: "Ekran Görüntüsü Koruması",
            settings_screenprotect_desc: "Ekran kaydı ve ekran alıntısı araçlarına karşı pencereyi karartır.",
            settings_screenprotect_active: "Aktif (Korumalı)",
            settings_screenprotect_disabled: "Devre Dışı (Görünür)",
            
            settings_master_pw_title: "Ana Parolayı Güncelle",
            settings_master_pw_desc: "Mevcut parolanızı doğrulayarak tüm kasayı yeni anahtarla yeniden şifreler.",
            settings_master_pw_btn: "Parolayı Değiştir...",
            
            settings_backup_vault_title: "Şifreli Yedek (.vault)",
            settings_backup_vault_desc: "Mevcut AES-256 anahtarıyla şifrelenmiş taşınabilir yedek dosyası oluşturun veya yükleyin.",
            settings_backup_export_btn: "Yedek Al (.vault)",
            settings_backup_import_btn: "Yedekten Geri Yükle",
            
            settings_csv_title: "Düz Metin Dışa Aktarma (CSV)",
            settings_csv_desc: "Şifreleri Excel / CSV formatında düz metin olarak dışa aktarır (Güvensiz).",
            settings_csv_export_btn: "CSV Olarak İndir",
            
            settings_wipe_title: "Tüm Kasayı Sıfırla (Wipe Vault)",
            settings_wipe_desc: "Tüm şifreleri ve kasayı geri döndürülemez şekilde kalıcı olarak siler.",
            settings_wipe_btn: "Kasayı Sıfırla...",
            
            sort_newest: "En Yeni",
            sort_oldest: "En Eski",
            sort_az: "Servis (A-Z)",
            sort_za: "Servis (Z-A)",
            
            lock_tooltip: "Kasayı Kilitle"
        },
        en: {
            app_title: "VoidPass",
            welcome_title: "Welcome",
            welcome_subtitle: "Please select your preferred language",
            welcome_tr_title: "Türkçe",
            welcome_tr_desc: "Turkey • Continue in Turkish",
            welcome_en_title: "English",
            welcome_en_desc: "United States • Continue in English",
            
            setup_title: "Welcome",
            setup_desc: "Set a strong master password to secure your vault.",
            setup_pw_label: "Master Password",
            setup_pw_placeholder: "Minimum 8 characters recommended",
            setup_confirm_label: "Confirm Master Password",
            setup_confirm_placeholder: "Re-enter your password",
            setup_create_btn: "Create Vault",
            
            login_title: "Vault Locked",
            login_desc: "Enter your master password to access your passwords.",
            login_pw_label: "Master Password",
            login_pw_placeholder: "Enter master password",
            login_unlock_btn: "Unlock Vault",
            
            search_placeholder: "Search vault... (Service or email)",
            add_password_btn: "+ Add New Password",
            
            health_score: "Security Score",
            health_all: "All",
            health_leaked: "Leaked",
            health_weak: "Weak",
            health_reused: "Reused",
            
            col_service: "SERVICE",
            col_username: "USERNAME",
            col_password: "PASSWORD",
            
            tooltip_hide: "Hide",
            tooltip_show: "Show",
            tooltip_copy: "Copy (cleared in 30s)",
            tooltip_edit: "Edit",
            tooltip_delete: "Delete",
            
            toast_deleted: "Password deleted.",
            toast_saved: "Password saved.",
            toast_updated: "Password updated.",
            toast_copied: "Password copied to clipboard! (Cleared in 30s)",
            toast_lang_tr: "Dil Türkçe olarak ayarlandı.",
            toast_lang_en: "Language set to English.",
            
            dialog_add_title: "Add New Password",
            dialog_edit_title: "Edit Password",
            dialog_service_label: "Service / Platform",
            dialog_service_placeholder: "e.g. Google, Netflix, Steam...",
            dialog_service_suggest: "Suggested Popular Services:",
            dialog_username_label: "Username or Email",
            dialog_username_placeholder: "e.g. user@example.com",
            dialog_password_label: "Password",
            dialog_password_placeholder: "Enter a strong password",
            dialog_generate_btn: "Generate",
            dialog_cancel_btn: "Cancel",
            dialog_save_btn: "Save",
            dialog_update_btn: "Save Changes",
            
            settings_title: "Settings",
            settings_subtitle: "Configure appearance, security and data management preferences",
            settings_back: "Go Back",
            settings_cat_appearance: "APPEARANCE & INTERFACE",
            settings_cat_security: "SECURITY & PROTECTION",
            settings_cat_backup: "BACKUP & DATA MANAGEMENT",
            settings_cat_danger: "DANGER ZONE",
            
            settings_lang_title: "Application Language",
            settings_lang_desc: "Select the interface language between Turkish and English.",
            
            settings_scale_title: "UI Scale",
            settings_scale_desc: "Scale the interface to fit your window size and screen resolution.",
            settings_scale_fit: "Fit to Screen",
            
            settings_wallpaper_title: "Background Wallpaper",
            settings_wallpaper_desc: "Set a custom wallpaper behind your vault interface.",
            settings_wallpaper_remove: "Remove Wallpaper",
            settings_wallpaper_select: "Select Image",
            settings_wallpaper_opacity: "Wallpaper Opacity",
            
            settings_autolock_title: "Auto-Lock Timeout",
            settings_autolock_desc: "Automatically locks the vault after inactive duration.",
            settings_autolock_disabled: "Disabled",
            settings_autolock_mins: "Minutes",
            
            settings_screenprotect_title: "Screenshot Protection",
            settings_screenprotect_desc: "Blackens the window for screen recorders and capture tools.",
            settings_screenprotect_active: "Active (Protected)",
            settings_screenprotect_disabled: "Disabled (Visible)",
            
            settings_master_pw_title: "Update Master Password",
            settings_master_pw_desc: "Re-encrypts the entire vault with a new master key.",
            settings_master_pw_btn: "Change Password...",
            
            settings_backup_vault_title: "Encrypted Backup (.vault)",
            settings_backup_vault_desc: "Create or restore an AES-256 encrypted portable backup file.",
            settings_backup_export_btn: "Export Backup (.vault)",
            settings_backup_import_btn: "Restore from Backup",
            
            settings_csv_title: "Plaintext Export (CSV)",
            settings_csv_desc: "Exports all passwords as unencrypted plaintext CSV (Insecure).",
            settings_csv_export_btn: "Download CSV",
            
            settings_wipe_title: "Wipe Entire Vault",
            settings_wipe_desc: "Permanently and irreversibly deletes all stored credentials.",
            settings_wipe_btn: "Wipe Vault...",
            
            sort_newest: "Newest",
            sort_oldest: "Oldest",
            sort_az: "Service (A-Z)",
            sort_za: "Service (Z-A)",
            
            lock_tooltip: "Lock Vault"
        }
    })

    function t(key) {
        var lang = translations[appLang] || translations["tr"]
        return (lang && lang[key] !== undefined) ? lang[key] : key
    }

    // Dinamik ve Sabit Tablo Kolon Genişlikleri (Tam ekranda eşit yayılma ve sıfır kayma)
    readonly property int tableAvailableWidth: Math.max(540, (passwordList ? passwordList.width : 900) - 32 - 176)
    readonly property int colServiceWidth: Math.max(180, Math.floor(tableAvailableWidth * 0.28))
    readonly property int colUsernameWidth: Math.max(220, Math.floor(tableAvailableWidth * 0.38))
    readonly property int colPasswordWidth: Math.max(160, tableAvailableWidth - colServiceWidth - colUsernameWidth)
    readonly property int colActionsWidth: 176
    
    // Parola Sağlığı Paneli Durumu
    property int healthScore: 100
    property int totalCount: 0
    property int weakCount: 0
    property int reusedCount: 0
    property int pwnedCount: 0
    property string healthFilter: "all"
    property string pendingRestoreFile: ""
    property var pendingRestoreInfo: null
    
    // 55 Popüler Marka / Servis Kataloğu
    readonly property var brandCatalog: [
        { id: "google", name: "Google", keys: ["google", "gmail", "youtube", "android", "chrome"] },
        { id: "outlook", name: "Outlook", keys: ["outlook", "hotmail", "live.com", "msn"] },
        { id: "microsoft", name: "Microsoft", keys: ["microsoft", "office", "windows", "azure", "onedrive"] },
        { id: "steam", name: "Steam", keys: ["steam", "valve"] },
        { id: "epicgames", name: "Epic Games", keys: ["epic", "epic games", "fortnite", "unreal"] },
        { id: "github", name: "GitHub", keys: ["github", "git"] },
        { id: "discord", name: "Discord", keys: ["discord"] },
        { id: "spotify", name: "Spotify", keys: ["spotify"] },
        { id: "netflix", name: "Netflix", keys: ["netflix"] },
        { id: "youtube", name: "YouTube", keys: ["youtube", "yt"] },
        { id: "x", name: "X (Twitter)", keys: ["twitter", "x.com", "tweet"] },
        { id: "instagram", name: "Instagram", keys: ["instagram", "insta", "ig"] },
        { id: "reddit", name: "Reddit", keys: ["reddit"] },
        { id: "twitch", name: "Twitch", keys: ["twitch"] },
        { id: "apple", name: "Apple", keys: ["apple", "icloud", "itunes", "app store", "ios", "mac"] },
        { id: "amazon", name: "Amazon", keys: ["amazon", "aws", "prime"] },
        { id: "openai", name: "OpenAI", keys: ["openai", "chatgpt", "chat gpt", "gpt"] },
        { id: "playstation", name: "PlayStation", keys: ["playstation", "psn", "ps4", "ps5", "sony"] },
        { id: "xbox", name: "Xbox", keys: ["xbox", "gamepass"] },
        { id: "riotgames", name: "Riot Games", keys: ["riot", "valorant", "lol", "league of legends"] },
        { id: "battlenet", name: "Battle.net", keys: ["battle.net", "battlenet", "blizzard", "overwatch", "diablo", "wow"] },
        { id: "ubisoft", name: "Ubisoft", keys: ["ubisoft", "uplay"] },
        { id: "ea", name: "EA", keys: ["electronic arts", "origin", "fifa", "apex", " ea "] },
        { id: "telegram", name: "Telegram", keys: ["telegram", "tg"] },
        { id: "whatsapp", name: "WhatsApp", keys: ["whatsapp", "wp"] },
        { id: "linkedin", name: "LinkedIn", keys: ["linkedin"] },
        { id: "tiktok", name: "TikTok", keys: ["tiktok"] },
        { id: "facebook", name: "Facebook", keys: ["facebook", "meta", "fb"] },
        { id: "dropbox", name: "Dropbox", keys: ["dropbox"] },
        { id: "notion", name: "Notion", keys: ["notion"] },
        { id: "figma", name: "Figma", keys: ["figma"] },
        { id: "gitlab", name: "GitLab", keys: ["gitlab"] },
        { id: "paypal", name: "PayPal", keys: ["paypal"] },
        { id: "adobe", name: "Adobe", keys: ["adobe", "photoshop", "illustrator"] },
        { id: "zoom", name: "Zoom", keys: ["zoom"] },
        { id: "cloudflare", name: "Cloudflare", keys: ["cloudflare"] },
        { id: "archlinux", name: "Arch Linux", keys: ["arch linux", "archlinux", "arch"] },
        { id: "docker", name: "Docker", keys: ["docker"] },
        { id: "pinterest", name: "Pinterest", keys: ["pinterest"] },
        { id: "kick", name: "Kick", keys: ["kick"] },
        { id: "roblox", name: "Roblox", keys: ["roblox"] },
        { id: "proton", name: "Proton", keys: ["proton", "protonmail", "protonvpn"] },
        { id: "bitwarden", name: "Bitwarden", keys: ["bitwarden"] },
        { id: "medium", name: "Medium", keys: ["medium"] },
        { id: "slack", name: "Slack", keys: ["slack"] },
        { id: "gog", name: "GOG", keys: ["gog", "galaxy"] },
        { id: "ebay", name: "eBay", keys: ["ebay"] },
        { id: "airbnb", name: "Airbnb", keys: ["airbnb"] },
        { id: "uber", name: "Uber", keys: ["uber"] },
        { id: "snapchat", name: "Snapchat", keys: ["snapchat", "snap"] },
        { id: "soundcloud", name: "SoundCloud", keys: ["soundcloud"] },
        { id: "patreon", name: "Patreon", keys: ["patreon"] },
        { id: "trello", name: "Trello", keys: ["trello"] },
        { id: "canva", name: "Canva", keys: ["canva"] },
        { id: "mega", name: "MEGA", keys: ["mega", "meganz"] }
    ]

    function getBrandInfo(serviceName) {
        if (!serviceName) return null;
        var s = serviceName.toString().trim().toLowerCase();
        if (s === "") return null;
        
        for (var i = 0; i < brandCatalog.length; i++) {
            var b = brandCatalog[i];
            if (s === b.id || s === b.name.toLowerCase()) {
                return { id: b.id, name: b.name, icon: "qrc:/icons/brands/" + b.id + ".svg" };
            }
            for (var k = 0; k < b.keys.length; k++) {
                if (s.indexOf(b.keys[k]) !== -1) {
                    return { id: b.id, name: b.name, icon: "qrc:/icons/brands/" + b.id + ".svg" };
                }
            }
        }
        return null;
    }

    function getMatchingBrands(query) {
        var q = (query || "").toString().trim().toLowerCase();
        var results = [];
        for (var i = 0; i < brandCatalog.length; i++) {
            var b = brandCatalog[i];
            if (q === "") {
                if (i < 15) results.push({ id: b.id, name: b.name, icon: "qrc:/icons/brands/" + b.id + ".svg" });
            } else {
                var match = (b.name.toLowerCase().indexOf(q) !== -1) || (b.id.indexOf(q) !== -1);
                if (!match) {
                    for (var k = 0; k < b.keys.length; k++) {
                        if (b.keys[k].indexOf(q) !== -1) {
                            match = true;
                            break;
                        }
                    }
                }
                if (match) {
                    results.push({ id: b.id, name: b.name, icon: "qrc:/icons/brands/" + b.id + ".svg" });
                }
            }
        }
        return results;
    }
    
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

    FileDialog {
        id: exportVaultDialog
        title: "Şifreli Kasayı Dışa Aktar (.vault)"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "vault"
        nameFilters: ["VoidPass Vault (*.vault)"]
        onAccepted: {
            if (vaultManager.exportVaultBackup(selectedFile)) {
                showToast("Şifreli .vault yedeği başarıyla oluşturuldu.")
            } else {
                showToast("Yedekleme işlemi başarısız oldu!")
            }
        }
    }

    FileDialog {
        id: importVaultDialog
        title: "Şifreli Kasayı İçe Aktar (.vault)"
        fileMode: FileDialog.OpenFile
        nameFilters: ["VoidPass Vault (*.vault)", "Tüm Dosyalar (*)"]
        onAccepted: {
            var info = vaultManager.inspectVaultBackup(selectedFile)
            if (!info.valid) {
                showToast("Geçersiz veya bozuk .vault yedek dosyası!")
                return
            }
            pendingRestoreFile = selectedFile
            pendingRestoreInfo = info
            restoreConfirmDialog.open()
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
            restoreConfirmDialog.close()
            exportCsvDialog.close()
            exportVaultDialog.close()
            importVaultDialog.close()
            vaultModel.clear()
            appState = 1
            showToast("Hareketsizlik nedeniyle kasa otomatik kilitlendi.")
        }
    }

    // Scaled Root Content Item (Arayüz Ölçeklendirme Kapsayıcısı)
    Item {
        id: scaledContent
        width: parent.width / uiScale
        height: parent.height / uiScale
        scale: uiScale
        transformOrigin: Item.TopLeft
        
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
                text: "VoidPass"
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

            Rectangle {
                Layout.preferredWidth: 320
                Layout.preferredHeight: 1
                color: borderMain
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            Button {
                text: "Yedekten Geri Yükle (.vault)"
                Layout.preferredWidth: 320
                Layout.preferredHeight: 40
                contentItem: RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Image {
                        source: "qrc:/icons/download.svg"
                        sourceSize: Qt.size(15, 15)
                    }
                    Text {
                        text: "Yedekten Geri Yükle (.vault)"
                        color: textMain
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
                background: Rectangle {
                    color: parent.down ? "#1f1f1f" : (parent.hovered ? bgHover : "transparent")
                    border.color: borderMain
                    radius: 4
                }
                onClicked: importVaultDialog.open()
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
            anchors.leftMargin: Math.max(20, Math.min(36, parent.width * 0.035))
            anchors.rightMargin: Math.max(20, Math.min(36, parent.width * 0.035))
            anchors.topMargin: Math.max(16, Math.min(28, parent.height * 0.035))
            anchors.bottomMargin: Math.max(16, Math.min(28, parent.height * 0.035))
            spacing: parent.height < 650 ? 16 : 24
            
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
                    placeholderText: t("search_placeholder")
                    Layout.preferredWidth: 260
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
                    model: [t("sort_newest"), t("sort_oldest"), t("sort_az"), t("sort_za")]
                    
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
                    text: t("add_password_btn")
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 160
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
                                text: t("add_password_btn")
                                color: bgMain
                                font.bold: true
                                font.pixelSize: 13
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
            
            // Parola Sağlığı & Filtre Çubuğu (Minimalist Bar)
            Rectangle {
                Layout.fillWidth: true
                height: 38
                color: wallpaperPath !== "" ? "#d90a0a0a" : "#0d0d0d"
                border.color: borderMain
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 14
                    
                    // Sol: Sağlık Göstergesi (Kompakt ve Sade)
                    RowLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter
                        
                        Image {
                            source: "qrc:/icons/shield.svg"
                            sourceSize: Qt.size(13, 13)
                            opacity: 0.8
                        }
                        
                        Text { 
                            text: (appLang === "en" ? "Vault Health: %" : "Kasa Sağlığı: %") + healthScore
                            color: textMain
                            font.pixelSize: 12
                            font.bold: true 
                        }
                        
                        Rectangle {
                            width: 36
                            height: 3
                            radius: 1.5
                            color: "#222222"
                            Rectangle {
                                width: parent.width * Math.min(1.0, Math.max(0.0, healthScore / 100.0))
                                height: parent.height
                                radius: 1.5
                                color: healthScore >= 80 ? "#10b981" : (healthScore >= 50 ? "#fbbf24" : danger)
                            }
                        }
                    }
                    
                    Rectangle {
                        width: 1
                        height: 14
                        color: borderMain
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    // Sağ: Sade Filtre Sekmeleri (Minimalist Segment Tabs)
                    RowLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        
                        Repeater {
                            model: [
                                { id: "all", label: t("health_all"), count: totalCount },
                                { id: "reused", label: t("health_reused"), count: reusedCount },
                                { id: "weak", label: t("health_weak"), count: weakCount },
                                { id: "pwned", label: t("health_leaked"), count: pwnedCount }
                            ]
                            
                            delegate: Rectangle {
                                id: tabItem
                                readonly property bool isSelected: healthFilter === modelData.id
                                readonly property bool isHovered: tabMouse.containsMouse
                                
                                height: 26
                                width: tabTxt.implicitWidth + 16
                                radius: 4
                                color: isSelected ? (wallpaperPath !== "" ? "#33ffffff" : "#222222") : (isHovered ? "#161616" : "transparent")
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
                                        if (modelData.id === "all") {
                                            healthFilter = "all"
                                        } else {
                                            healthFilter = healthFilter === modelData.id ? "all" : modelData.id
                                        }
                                        loadData()
                                    }
                                }
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
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.preferredHeight: 28
                spacing: 0
                
                Item {
                    Layout.preferredWidth: colServiceWidth
                    Layout.minimumWidth: colServiceWidth
                    Layout.maximumWidth: colServiceWidth
                    Layout.fillHeight: true
                    Text { 
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: t("col_service")
                        color: textMuted
                        font.bold: true
                        font.pixelSize: 11
                        font.letterSpacing: 1
                    }
                }
                
                Item {
                    Layout.preferredWidth: colUsernameWidth
                    Layout.minimumWidth: colUsernameWidth
                    Layout.maximumWidth: colUsernameWidth
                    Layout.fillHeight: true
                    Text { 
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: t("col_username")
                        color: textMuted
                        font.bold: true
                        font.pixelSize: 11
                        font.letterSpacing: 1
                    }
                }
                
                Item {
                    Layout.preferredWidth: colPasswordWidth
                    Layout.minimumWidth: colPasswordWidth
                    Layout.maximumWidth: colPasswordWidth
                    Layout.fillHeight: true
                    Text { 
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: t("col_password")
                        color: textMuted
                        font.bold: true
                        font.pixelSize: 11
                        font.letterSpacing: 1
                    }
                }
                
                Item { 
                    Layout.preferredWidth: colActionsWidth
                    Layout.minimumWidth: colActionsWidth
                    Layout.maximumWidth: colActionsWidth
                    Layout.fillHeight: true
                }
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
                        
                        // Kolon 1: Servis ve Marka İkonu (Orantılı Dağılım)
                        Item {
                            Layout.preferredWidth: colServiceWidth
                            Layout.minimumWidth: colServiceWidth
                            Layout.maximumWidth: colServiceWidth
                            Layout.fillHeight: true
                            clip: true
                            
                            RowLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12
                                
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
                                
                                Text {
                                    text: model.service ? model.service : "Bilinmiyor (Eski)"
                                    color: textMain
                                    font.pixelSize: 14
                                    font.bold: true
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                        
                        // Kolon 2: Kullanıcı Adı / E-posta (Orantılı Dağılım)
                        Item {
                            Layout.preferredWidth: colUsernameWidth
                            Layout.minimumWidth: colUsernameWidth
                            Layout.maximumWidth: colUsernameWidth
                            Layout.fillHeight: true
                            clip: true
                            
                            Text { 
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                text: model.username
                                color: textMuted
                                font.pixelSize: 14
                                elide: Text.ElideRight
                            }
                        }
                        
                        // Kolon 3: Parola ve Rozet (Orantılı Dağılım - Sıfır Jitter)
                        Item {
                            Layout.preferredWidth: colPasswordWidth
                            Layout.minimumWidth: colPasswordWidth
                            Layout.maximumWidth: colPasswordWidth
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
                                    font.pixelSize: 14
                                    font.letterSpacing: showPassword ? 0 : 2
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: parent.width - (warnBadge.visible ? 34 : 0)
                                }
                                
                                // Birleşik Güvenlik Uyarısı Rozeti (Tek rozet, çoklu mesaj)
                                Rectangle {
                                    id: warnBadge
                                    readonly property bool hasPwned: Boolean(model.isPwned)
                                    readonly property bool hasWeak: Boolean(model.isWeak)
                                    readonly property bool hasReused: Boolean(model.isReused)
                                    readonly property bool hasIssue: hasPwned || hasWeak || hasReused
                                    
                                    visible: hasIssue
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 22
                                    radius: 4
                                    color: (hasPwned || hasWeak) ? "#26ff4444" : "#26fbbf24"
                                    border.color: (hasPwned || hasWeak) ? danger : "#fbbf24"
                                    border.width: 1
                                    
                                    Image {
                                        anchors.centerIn: parent
                                        width: 14
                                        height: 14
                                        sourceSize: Qt.size(14, 14)
                                        fillMode: Image.PreserveAspectFit
                                        source: (hasPwned || hasWeak) ? "qrc:/icons/alert.svg" : "qrc:/icons/copy.svg"
                                    }
                                    
                                    ToolTip.visible: warnHover.containsMouse
                                    ToolTip.delay: 200
                                    ToolTip.text: {
                                        var msgs = []
                                        if (hasPwned) msgs.push("• Sızıntı Uyarısı: Bu şifre veri sızıntılarında (HIBP) açığa çıkmış!")
                                        if (hasWeak) msgs.push("• Zayıf Şifre: Kolay tahmin edilebilir, en az 8+ karmaşık karakter önerilir.")
                                        if (hasReused) msgs.push("• Tekrar Eden Şifre: Birden fazla hesapta ortak kullanılmış.")
                                        return msgs.join("\n")
                                    }
                                    
                                    MouseArea {
                                        id: warnHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                            }
                        }
                        
                        // Kolon 4: Eylemler (Sabit Genişlik)
                        Item {
                            Layout.preferredWidth: colActionsWidth
                            Layout.minimumWidth: colActionsWidth
                            Layout.maximumWidth: colActionsWidth
                            Layout.fillHeight: true
                            
                            RowLayout {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12
                                
                                Button {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    icon.source: showPassword ? "qrc:/icons/eye-off.svg" : "qrc:/icons/eye.svg"
                                    icon.color: hovered ? "#000000" : textMain
                                    icon.width: 16
                                    icon.height: 16
                                    display: AbstractButton.IconOnly
                                    ToolTip.visible: hovered
                                    ToolTip.text: showPassword ? t("tooltip_hide") : t("tooltip_show")
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
                                    ToolTip.text: t("tooltip_copy")
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
                                    ToolTip.text: t("tooltip_edit")
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
                                    ToolTip.text: t("tooltip_delete")
                                    background: Rectangle { 
                                        color: parent.hovered ? danger : "transparent"
                                        radius: 4 
                                    }
                                    onClicked: {
                                        vaultManager.deleteEntry(model.id)
                                        loadData()
                                        showToast(t("toast_deleted"))
                                    }
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
            anchors.margins: parent.width < 900 ? 20 : 32
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
        }
    }
    
    // Settings Fullscreen Page (Derli Toplu ve Kategorize Edilmiş)
    Item {
        anchors.fill: parent
        visible: appState === 3
        
        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 24
            anchors.bottomMargin: 16
            anchors.leftMargin: Math.max(20, (parent.width - 840) / 2)
            anchors.rightMargin: Math.max(20, (parent.width - 840) / 2)
            spacing: 16
            
            // Top Bar with Back Button & Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Button {
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
                        text: t("settings_title")
                        color: textMain
                        font.pixelSize: 22
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    Text {
                        text: t("settings_subtitle")
                        color: textMuted
                        font.pixelSize: 12
                    }
                }
            }
            
            // Scrollable Structured Settings List
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 6
                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: 3
                        color: parent.pressed ? "#666666" : (parent.hovered ? "#444444" : "#2a2a2a")
                    }
                }
                
                ColumnLayout {
                    width: parent.width - 12
                    spacing: 12
                    
                    // ========================================================
                    // 1. BÖLÜM: GÖRÜNÜM & ARAYÜZ
                    // ========================================================
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        spacing: 8
                        Text {
                            text: t("settings_cat_appearance")
                            color: "#888888"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.5
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#222222" }
                    }
                    
                    // 1.0 Dil Seçimi (Türkçe & English Yuvarlak Bayraklar)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 88
                        color: bgSecondary
                        border.color: borderMain
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            spacing: 16
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text { 
                                    text: t("settings_lang_title")
                                    color: textMain
                                    font.pixelSize: 14
                                    font.bold: true 
                                }
                                Text { 
                                    text: t("settings_lang_desc")
                                    color: textMuted
                                    font.pixelSize: 12 
                                }
                            }
                            
                            RowLayout {
                                spacing: 10
                                Layout.alignment: Qt.AlignVCenter
                                
                                // Türkçe Butonu
                                Rectangle {
                                    width: 124
                                    height: 42
                                    radius: 8
                                    color: appLang === "tr" ? "#222222" : (btnTrHov.hovered ? "#161616" : "#0f0f0f")
                                    border.color: appLang === "tr" ? "#ffffff" : "#333333"
                                    border.width: appLang === "tr" ? 2 : 1
                                    
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        Image {
                                            width: 22
                                            height: 22
                                            source: "qrc:/icons/flag_tr.svg"
                                            sourceSize: Qt.size(22, 22)
                                        }
                                        Text {
                                            text: "Türkçe"
                                            color: appLang === "tr" ? textMain : textMuted
                                            font.pixelSize: 13
                                            font.bold: appLang === "tr"
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: btnTrHov
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            appLang = "tr"
                                            vaultManager.setLanguage("tr")
                                            showToast(t("toast_lang_tr"))
                                        }
                                    }
                                }
                                
                                // English Butonu
                                Rectangle {
                                    width: 124
                                    height: 42
                                    radius: 8
                                    color: appLang === "en" ? "#222222" : (btnEnHov.hovered ? "#161616" : "#0f0f0f")
                                    border.color: appLang === "en" ? "#ffffff" : "#333333"
                                    border.width: appLang === "en" ? 2 : 1
                                    
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        Image {
                                            width: 22
                                            height: 22
                                            source: "qrc:/icons/flag_us.svg"
                                            sourceSize: Qt.size(22, 22)
                                        }
                                        Text {
                                            text: "English"
                                            color: appLang === "en" ? textMain : textMuted
                                            font.pixelSize: 13
                                            font.bold: appLang === "en"
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: btnEnHov
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            appLang = "en"
                                            vaultManager.setLanguage("en")
                                            showToast(t("toast_lang_en"))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 1.1 Arayüz Ölçeği
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 116
                        color: bgSecondary
                        border.color: borderMain
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 16
                                
                                Rectangle {
                                    width: 40; height: 40; radius: 8; color: "#141414"; border.color: borderMain
                                    Image { source: "qrc:/icons/eye.svg"; width: 20; height: 20; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text { text: "Arayüz Ölçeği"; color: textMain; font.pixelSize: 15; font.bold: true }
                                    Text { text: "Tüm metin ve bileşen boyutlarını ekranınıza göre ölçeklendirin."; color: textMuted; font.pixelSize: 13 }
                                }
                                
                                Text {
                                    text: "%" + Math.round(uiScale * 100)
                                    color: accent
                                    font.pixelSize: 16
                                    font.bold: true
                                    Layout.preferredWidth: 60
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 16
                                
                                Slider {
                                    id: scaleSlider
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 20
                                    from: 0.85
                                    to: 1.30
                                    stepSize: 0.05
                                    value: uiScale
                                    onMoved: {
                                        var val = Math.round(value * 100) / 100
                                        uiScale = val
                                        vaultManager.setUiScale(val)
                                    }
                                    
                                    background: Rectangle {
                                        x: scaleSlider.leftPadding
                                        y: scaleSlider.topPadding + scaleSlider.availableHeight / 2 - height / 2
                                        width: scaleSlider.availableWidth
                                        height: 4
                                        radius: 2
                                        color: borderMain
                                        Rectangle {
                                            width: scaleSlider.visualPosition * parent.width
                                            height: parent.height
                                            color: accent
                                            radius: 2
                                        }
                                    }
                                    handle: Rectangle {
                                        x: scaleSlider.leftPadding + scaleSlider.visualPosition * (scaleSlider.availableWidth - width)
                                        y: scaleSlider.topPadding + scaleSlider.availableHeight / 2 - height / 2
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: scaleSlider.pressed ? "#f0f0f0" : textMain
                                    }
                                }
                                
                                Row {
                                    spacing: 6
                                    Repeater {
                                        model: [
                                            { label: "%85", val: 0.85 },
                                            { label: "%100", val: 1.00 },
                                            { label: "%115", val: 1.15 },
                                            { label: "%125", val: 1.25 }
                                        ]
                                        Rectangle {
                                            width: 52
                                            height: 28
                                            radius: 6
                                            color: Math.abs(uiScale - modelData.val) < 0.02 ? accent : (presetMa.hovered ? bgHover : "#141414")
                                            border.color: Math.abs(uiScale - modelData.val) < 0.02 ? accent : borderMain
                                            border.width: 1
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.label
                                                color: Math.abs(uiScale - modelData.val) < 0.02 ? bgMain : textMain
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                            MouseArea {
                                                id: presetMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    uiScale = modelData.val
                                                    scaleSlider.value = modelData.val
                                                    vaultManager.setUiScale(modelData.val)
                                                    showToast("Arayüz ölçeği " + modelData.label + " olarak ayarlandı.")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 1.2 Özel Duvar Kağıdı ve Opaklık
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: wallpaperPath !== "" ? 116 : 74
                        color: bgSecondary
                        border.color: borderMain
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 16
                                
                                Rectangle {
                                    width: 40; height: 40; radius: 8; color: "#141414"; border.color: borderMain
                                    Image { source: "qrc:/icons/image.svg"; width: 20; height: 20; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text { text: "Özel Duvar Kağıdı"; color: textMain; font.pixelSize: 15; font.bold: true }
                                    Text { text: wallpaperPath !== "" ? ("Opaklık: %" + Math.round(wallpaperOpacity * 100)) : "Arka planda estetik duracak bir görsel seçin."; color: textMuted; font.pixelSize: 13 }
                                }
                                
                                Button {
                                    text: wallpaperPath === "" ? "Görsel Seç" : "Değiştir"
                                    Layout.preferredWidth: 90
                                    Layout.preferredHeight: 36
                                    background: Rectangle { color: parent.hovered ? bgHover : "#141414"; radius: 6; border.color: borderMain }
                                    contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: wallpaperDialog.open()
                                }
                                
                                Button {
                                    visible: wallpaperPath !== ""
                                    text: "Kaldır"
                                    Layout.preferredWidth: 64
                                    Layout.preferredHeight: 36
                                    background: Rectangle { color: danger; radius: 6 }
                                    contentItem: Text { text: parent.text; color: bgMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: {
                                        wallpaperPath = ""
                                        vaultManager.setWallpaper("")
                                    }
                                }
                            }
                            
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
                    }
                    
                    // ========================================================
                    // 2. BÖLÜM: GÜVENLİK & KORUMA
                    // ========================================================
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        spacing: 8
                        Text {
                            text: t("settings_cat_security")
                            color: "#888888"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.5
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#222222" }
                    }
                    
                    // 2.1 Ana Parolayı Güncelle
                    Rectangle {
                        Layout.fillWidth: true
                        height: 74
                        color: bgSecondary
                        border.color: borderMain
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16
                            
                            Rectangle {
                                width: 40; height: 40; radius: 8; color: "#141414"; border.color: borderMain
                                Image { source: "qrc:/icons/key.svg"; width: 20; height: 20; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "Ana Parolayı Değiştir"; color: textMain; font.pixelSize: 15; font.bold: true }
                                Text { text: "Kasa anahtarını günceller ve tüm kayıtları atomik olarak yeni anahtarla yeniden şifreler."; color: textMuted; font.pixelSize: 13 }
                            }
                            
                            Button {
                                text: "Değiştir"
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36
                                background: Rectangle { color: parent.hovered ? bgHover : "#141414"; radius: 6; border.color: borderMain }
                                contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                onClicked: changeMasterPwdDialog.open()
                            }
                        }
                    }
                    
                    // 2.2 Ekran Görüntüsü ve Casus Koruması
                    Rectangle {
                        Layout.fillWidth: true
                        height: 74
                        color: bgSecondary
                        border.color: borderMain
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16
                            
                            Rectangle {
                                width: 40; height: 40; radius: 8; color: "#141414"; border.color: borderMain
                                Image { source: "qrc:/icons/shield.svg"; width: 20; height: 20; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "Ekran Görüntüsü Koruması"; color: textMain; font.pixelSize: 15; font.bold: true }
                                Text { text: "OBS, Discord yayınları ve Snipping Tool gibi ekran yakalama araçlarını engeller."; color: textMuted; font.pixelSize: 13 }
                            }
                            
                            Switch {
                                id: screenshotSwitch
                                checked: true
                                onCheckedChanged: vaultManager.setScreenshotProtection(checked)
                                indicator: Rectangle {
                                    implicitWidth: 48
                                    implicitHeight: 26
                                    radius: 13
                                    color: screenshotSwitch.checked ? accent : "#141414"
                                    border.color: screenshotSwitch.checked ? accent : borderMain
                                    
                                    Rectangle {
                                        x: screenshotSwitch.checked ? parent.width - width - 2 : 2
                                        y: 2
                                        width: 22
                                        height: 22
                                        radius: 11
                                        color: screenshotSwitch.checked ? bgMain : textMain
                                        Behavior on x { NumberAnimation { duration: 200 } }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 2.3 Otomatik Kilit
                    Rectangle {
                        Layout.fillWidth: true
                        height: 74
                        color: bgSecondary
                        border.color: borderMain
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16
                            
                            Rectangle {
                                width: 40; height: 40; radius: 8; color: "#141414"; border.color: borderMain
                                Image { source: "qrc:/icons/clock.svg"; width: 20; height: 20; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "Otomatik Kilit"; color: textMain; font.pixelSize: 15; font.bold: true }
                                Text { text: "Belirli bir süre boşta kalındığında kasayı otomatik olarak kilitler."; color: textMuted; font.pixelSize: 13 }
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
                                    color: "#141414"
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
                    
                    // ========================================================
                    // 3. BÖLÜM: YEDEKLEME & VERİ YÖNETİMİ
                    // ========================================================
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        spacing: 8
                        Text {
                            text: t("settings_cat_backup")
                            color: "#888888"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.5
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#222222" }
                    }
                    
                    // 3.1 Şifreli Kasa Yedeği (.vault)
                    Rectangle {
                        Layout.fillWidth: true
                        height: 74
                        color: bgSecondary
                        border.color: borderMain
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16
                            
                            Rectangle {
                                width: 40; height: 40; radius: 8; color: "#141414"; border.color: borderMain
                                Image { source: "qrc:/icons/lock.svg"; width: 20; height: 20; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "Şifreli Yedek (.vault)"; color: textMain; font.pixelSize: 15; font.bold: true }
                                Text { text: "Şifreleri çözmeden mevcut AES-256 anahtarıyla güvenli taşınabilir yedek oluşturur."; color: textMuted; font.pixelSize: 13 }
                            }
                            
                            Button {
                                text: "Yedek Al"
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36
                                background: Rectangle { color: parent.hovered ? bgHover : "#141414"; radius: 6; border.color: borderMain }
                                contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                onClicked: exportVaultDialog.open()
                            }
                        }
                    }
                    
                    // 3.2 Yedekten Geri Yükle (.vault)
                    Rectangle {
                        Layout.fillWidth: true
                        height: 74
                        color: bgSecondary
                        border.color: borderMain
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16
                            
                            Rectangle {
                                width: 40; height: 40; radius: 8; color: "#141414"; border.color: borderMain
                                Image { source: "qrc:/icons/download.svg"; width: 20; height: 20; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "Yedekten Geri Yükle / Taşı"; color: textMain; font.pixelSize: 15; font.bold: true }
                                Text { text: "Windows veya Arch Linux'tan aldığınız .vault yedeğini geri yükleyin veya birleştirin."; color: textMuted; font.pixelSize: 13 }
                            }
                            
                            Button {
                                text: "Geri Yükle"
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36
                                background: Rectangle { color: parent.hovered ? bgHover : "#141414"; radius: 6; border.color: borderMain }
                                contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                onClicked: importVaultDialog.open()
                            }
                        }
                    }
                    
                    // 3.3 Şifresiz CSV Dışa Aktarımı
                    Rectangle {
                        Layout.fillWidth: true
                        height: 74
                        color: bgSecondary
                        border.color: borderMain
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16
                            
                            Rectangle {
                                width: 40; height: 40; radius: 8; color: "#141414"; border.color: borderMain
                                Image { source: "qrc:/icons/edit.svg"; width: 20; height: 20; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "Dışa Aktar (CSV)"; color: textMain; font.pixelSize: 15; font.bold: true }
                                Text { text: "Tüm şifreleri Excel ve diğer yöneticilerle uyumlu şifresiz CSV olarak aktarır."; color: textMuted; font.pixelSize: 13 }
                            }
                            
                            Button {
                                text: "CSV Aktar"
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36
                                background: Rectangle { color: parent.hovered ? bgHover : "#141414"; radius: 6; border.color: borderMain }
                                contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                onClicked: exportCsvDialog.open()
                            }
                        }
                    }
                    
                    // ========================================================
                    // 4. BÖLÜM: TEHLİKELİ BÖLGE
                    // ========================================================
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        spacing: 8
                        Text {
                            text: t("settings_cat_danger")
                            color: danger
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.5
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#441a1a" }
                    }
                    
                    // 4.1 Kasayı Tamamen Sıfırla
                    Rectangle {
                        Layout.fillWidth: true
                        height: 74
                        color: "#120808"
                        border.color: "#88ff4444"
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16
                            
                            Rectangle {
                                width: 40; height: 40; radius: 8; color: "#22ff4444"; border.color: "#66ff4444"
                                Image { source: "qrc:/icons/trash.svg"; width: 20; height: 20; sourceSize: Qt.size(20,20); anchors.centerIn: parent }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "Kasayı Tamamen Sıfırla"; color: danger; font.pixelSize: 15; font.bold: true }
                                Text { text: "Tüm veritabanı kayıtlarını ve anahtarları kalıcı olarak siler. Geri alınamaz."; color: textMuted; font.pixelSize: 13 }
                            }
                            
                            Button {
                                text: "Kasayı Sil"
                                Layout.preferredWidth: 90
                                Layout.preferredHeight: 36
                                background: Rectangle { color: parent.hovered ? "#ff2222" : danger; radius: 6 }
                                contentItem: Text { text: parent.text; color: bgMain; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                onClicked: {
                                    vaultManager.wipeVault()
                                    vaultModel.clear()
                                    appState = 0
                                }
                            }
                        }
                    }
                    
                    Item { height: 24 }
                }
            }
        }
    }
    } // End of scaledContent
    
    // Add Dialog (Enlarged & Brand-Aware)
    Dialog {
        id: addDialog
        x: (parent.width - width * scale) / 2
        y: (parent.height - height * scale) / 2
        width: Math.min(540, parent.width / uiScale - 40)
        scale: Math.min(1.2, Math.max(0.85, uiScale))
        transformOrigin: Item.Center
        parent: Overlay.overlay
        modal: true
        
        property bool showPassword: false
        readonly property var addBrandInfo: getBrandInfo(addService.text)
        
        onAboutToShow: {
            showPassword = false
        }
        
        background: Rectangle {
            color: bgSecondary
            radius: 12
            border.color: borderMain
            border.width: 1
        }
        
        contentItem: ColumnLayout {
            spacing: 18
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 14
                
                Rectangle {
                    width: 44
                    height: 44
                    radius: 10
                    color: "#141414"
                    border.color: addBrandInfo ? accent : borderMain
                    border.width: addBrandInfo ? 1.5 : 1
                    
                    Image {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        sourceSize.width: 22
                        sourceSize.height: 22
                        fillMode: Image.PreserveAspectFit
                        source: addBrandInfo ? addBrandInfo.icon : ""
                        visible: addBrandInfo !== null
                    }
                    
                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        sourceSize.width: 20
                        sourceSize.height: 20
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/icons/plus.svg"
                        visible: addBrandInfo === null
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "Yeni Şifre Ekle"
                        color: textMain
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Text {
                        text: addBrandInfo ? (addBrandInfo.name + " hesabı ekleniyor") : "Kasanıza yeni bir hesap ve parola ekleyin"
                        color: addBrandInfo ? "#a3a3a3" : textMuted
                        font.pixelSize: 12
                    }
                }
                
                Button {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    background: Rectangle {
                        color: parent.hovered ? bgHover : "transparent"
                        radius: 16
                    }
                    contentItem: Text {
                        text: "✕"
                        color: textMuted
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: addDialog.close()
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: borderMain
            }
            
            // Servis Alanı ve Canlı Marka Önerileri
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Text {
                    text: "SERVİS VEYA MARKA"
                    color: textMuted
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1
                }
                
                TextField {
                    id: addService
                    placeholderText: "Örn: Google, Steam, Epic Games, GitHub..."
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    color: textMain
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#0d0d0d"
                        radius: 6
                        border.color: addService.activeFocus ? accent : borderMain
                        border.width: 1
                    }
                    leftPadding: 14
                    rightPadding: 14
                }
                
                // Canlı Marka Öneri Çipleri (Tak Diye Seçim)
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    contentWidth: addBrandChipsRow.width
                    contentHeight: 34
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    
                    Row {
                        id: addBrandChipsRow
                        spacing: 8
                        
                        Repeater {
                            model: getMatchingBrands(addService.text)
                            
                            Rectangle {
                                height: 32
                                width: addChipRow.width + 20
                                radius: 16
                                color: addChipMa.hovered ? "#2a2a2a" : "#141414"
                                border.color: (addBrandInfo && addBrandInfo.id === modelData.id) ? accent : "#2a2a2a"
                                border.width: 1
                                
                                Row {
                                    id: addChipRow
                                    anchors.centerIn: parent
                                    spacing: 6
                                    
                                    Image {
                                        width: 14
                                        height: 14
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                        fillMode: Image.PreserveAspectFit
                                        source: modelData.icon
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Text {
                                        text: modelData.name
                                        color: textMain
                                        font.pixelSize: 12
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: addChipMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        addService.text = modelData.name
                                        addUsername.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Kullanıcı Adı
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Text {
                    text: "KULLANICI ADI VEYA E-POSTA"
                    color: textMuted
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1
                }
                
                TextField {
                    id: addUsername
                    placeholderText: "kullanici@example.com veya rumuz"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    color: textMain
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#0d0d0d"
                        radius: 6
                        border.color: addUsername.activeFocus ? accent : borderMain
                        border.width: 1
                    }
                    leftPadding: 14
                    rightPadding: 14
                }
            }
            
            // Parola Alanı
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Text {
                    text: "PAROLA"
                    color: textMuted
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    TextField {
                        id: addPassword
                        placeholderText: "Hesap parolası"
                        echoMode: addDialog.showPassword ? TextInput.Normal : TextInput.Password
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        color: textMain
                        font.pixelSize: 14
                        background: Rectangle {
                            color: "#0d0d0d"
                            radius: 6
                            border.color: addPassword.activeFocus ? accent : borderMain
                            border.width: 1
                        }
                        leftPadding: 14
                        rightPadding: 14
                    }
                    
                    Button {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46
                        icon.source: addDialog.showPassword ? "qrc:/icons/eye-off.svg" : "qrc:/icons/eye.svg"
                        icon.color: hovered ? "#000000" : textMain
                        icon.width: 18
                        icon.height: 18
                        display: AbstractButton.IconOnly
                        background: Rectangle {
                            color: parent.hovered ? textMain : bgHover
                            radius: 6
                        }
                        onClicked: addDialog.showPassword = !addDialog.showPassword
                    }
                    
                    Button {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46
                        icon.source: "qrc:/icons/dice.svg"
                        icon.color: hovered ? "#000000" : textMain
                        icon.width: 18
                        icon.height: 18
                        display: AbstractButton.IconOnly
                        background: Rectangle {
                            color: parent.hovered ? textMain : bgHover
                            radius: 6
                        }
                        onClicked: addPassword.text = passwordGen.generate(16)
                    }
                }
                
                // Güç Göstergesi
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
            
            Item { Layout.preferredHeight: 4 }
            
            // Aksiyon Butonları
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "İptal"
                    Layout.preferredHeight: 42
                    Layout.preferredWidth: 110
                    background: Rectangle {
                        color: parent.hovered ? bgHover : "transparent"
                        radius: 6
                        border.color: borderMain
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        color: textMain
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: addDialog.close()
                }
                
                Button {
                    text: "Kaydet"
                    Layout.preferredHeight: 42
                    Layout.preferredWidth: 120
                    background: Rectangle {
                        color: parent.hovered ? accentHover : accent
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: bgMain
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
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
    
    // Edit Dialog (Enlarged & Brand-Aware)
    Dialog {
        id: editDialog
        x: (parent.width - width * scale) / 2
        y: (parent.height - height * scale) / 2
        width: Math.min(540, parent.width / uiScale - 40)
        scale: Math.min(1.2, Math.max(0.85, uiScale))
        transformOrigin: Item.Center
        parent: Overlay.overlay
        modal: true
        
        property int entryId: 0
        property alias serviceText: editService.text
        property alias usernameText: editUsername.text
        property alias passwordText: editPassword.text
        property bool showPassword: false
        readonly property var editBrandInfo: getBrandInfo(editService.text)
        
        onAboutToShow: {
            showPassword = false
        }
        
        background: Rectangle {
            color: bgSecondary
            radius: 12
            border.color: borderMain
            border.width: 1
        }
        
        contentItem: ColumnLayout {
            spacing: 18
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 14
                
                Rectangle {
                    width: 44
                    height: 44
                    radius: 10
                    color: "#141414"
                    border.color: editBrandInfo ? accent : borderMain
                    border.width: editBrandInfo ? 1.5 : 1
                    
                    Image {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        sourceSize.width: 22
                        sourceSize.height: 22
                        fillMode: Image.PreserveAspectFit
                        source: editBrandInfo ? editBrandInfo.icon : ""
                        visible: editBrandInfo !== null
                    }
                    
                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        sourceSize.width: 20
                        sourceSize.height: 20
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/icons/edit.svg"
                        visible: editBrandInfo === null
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "Şifreyi Düzenle"
                        color: textMain
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Text {
                        text: editBrandInfo ? (editBrandInfo.name + " hesabı düzenleniyor") : "Kayıtlı hesap ve parola detaylarını güncelleyin"
                        color: editBrandInfo ? "#a3a3a3" : textMuted
                        font.pixelSize: 12
                    }
                }
                
                Button {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    background: Rectangle {
                        color: parent.hovered ? bgHover : "transparent"
                        radius: 16
                    }
                    contentItem: Text {
                        text: "✕"
                        color: textMuted
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: editDialog.close()
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: borderMain
            }
            
            // Servis Alanı ve Canlı Marka Önerileri
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Text {
                    text: "SERVİS VEYA MARKA"
                    color: textMuted
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1
                }
                
                TextField {
                    id: editService
                    placeholderText: "Örn: Google, Steam, Epic Games, GitHub..."
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    color: textMain
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#0d0d0d"
                        radius: 6
                        border.color: editService.activeFocus ? accent : borderMain
                        border.width: 1
                    }
                    leftPadding: 14
                    rightPadding: 14
                }
                
                // Canlı Marka Öneri Çipleri (Tak Diye Seçim)
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    contentWidth: editBrandChipsRow.width
                    contentHeight: 34
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    
                    Row {
                        id: editBrandChipsRow
                        spacing: 8
                        
                        Repeater {
                            model: getMatchingBrands(editService.text)
                            
                            Rectangle {
                                height: 32
                                width: editChipRow.width + 20
                                radius: 16
                                color: editChipMa.hovered ? "#2a2a2a" : "#141414"
                                border.color: (editBrandInfo && editBrandInfo.id === modelData.id) ? accent : "#2a2a2a"
                                border.width: 1
                                
                                Row {
                                    id: editChipRow
                                    anchors.centerIn: parent
                                    spacing: 6
                                    
                                    Image {
                                        width: 14
                                        height: 14
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                        fillMode: Image.PreserveAspectFit
                                        source: modelData.icon
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Text {
                                        text: modelData.name
                                        color: textMain
                                        font.pixelSize: 12
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: editChipMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        editService.text = modelData.name
                                        editUsername.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Kullanıcı Adı
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Text {
                    text: "KULLANICI ADI VEYA E-POSTA"
                    color: textMuted
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1
                }
                
                TextField {
                    id: editUsername
                    placeholderText: "kullanici@example.com veya rumuz"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    color: textMain
                    font.pixelSize: 14
                    background: Rectangle {
                        color: "#0d0d0d"
                        radius: 6
                        border.color: editUsername.activeFocus ? accent : borderMain
                        border.width: 1
                    }
                    leftPadding: 14
                    rightPadding: 14
                }
            }
            
            // Parola Alanı
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Text {
                    text: "PAROLA"
                    color: textMuted
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    TextField {
                        id: editPassword
                        placeholderText: "Hesap parolası"
                        echoMode: editDialog.showPassword ? TextInput.Normal : TextInput.Password
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        color: textMain
                        font.pixelSize: 14
                        background: Rectangle {
                            color: "#0d0d0d"
                            radius: 6
                            border.color: editPassword.activeFocus ? accent : borderMain
                            border.width: 1
                        }
                        leftPadding: 14
                        rightPadding: 14
                    }
                    
                    Button {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46
                        icon.source: editDialog.showPassword ? "qrc:/icons/eye-off.svg" : "qrc:/icons/eye.svg"
                        icon.color: hovered ? "#000000" : textMain
                        icon.width: 18
                        icon.height: 18
                        display: AbstractButton.IconOnly
                        background: Rectangle {
                            color: parent.hovered ? textMain : bgHover
                            radius: 6
                        }
                        onClicked: editDialog.showPassword = !editDialog.showPassword
                    }
                    
                    Button {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46
                        icon.source: "qrc:/icons/dice.svg"
                        icon.color: hovered ? "#000000" : textMain
                        icon.width: 18
                        icon.height: 18
                        display: AbstractButton.IconOnly
                        background: Rectangle {
                            color: parent.hovered ? textMain : bgHover
                            radius: 6
                        }
                        onClicked: editPassword.text = passwordGen.generate(16)
                    }
                }
                
                // Güç Göstergesi
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
            
            Item { Layout.preferredHeight: 4 }
            
            // Aksiyon Butonları
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "İptal"
                    Layout.preferredHeight: 42
                    Layout.preferredWidth: 110
                    background: Rectangle {
                        color: parent.hovered ? bgHover : "transparent"
                        radius: 6
                        border.color: borderMain
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        color: textMain
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: editDialog.close()
                }
                
                Button {
                    text: "Güncelle"
                    Layout.preferredHeight: 42
                    Layout.preferredWidth: 120
                    background: Rectangle {
                        color: parent.hovered ? accentHover : accent
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: bgMain
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
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
        x: (parent.width - width * scale) / 2
        y: (parent.height - height * scale) / 2
        width: Math.min(460, parent.width / uiScale - 40)
        scale: Math.min(1.2, Math.max(0.85, uiScale))
        transformOrigin: Item.Center
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
    
    // Şifreli Yedek Geri Yükleme Onay Modalı
    Dialog {
        id: restoreConfirmDialog
        x: (parent.width - width * scale) / 2
        y: (parent.height - height * scale) / 2
        width: Math.min(460, parent.width / uiScale - 40)
        scale: Math.min(1.2, Math.max(0.85, uiScale))
        transformOrigin: Item.Center
        modal: true
        dim: true
        closePolicy: Dialog.CloseOnEscape | Dialog.CloseOnPressOutside
        
        background: Rectangle {
            color: wallpaperPath !== "" ? "#e6121212" : "#121212"
            border.color: borderMain
            radius: 8
        }
        
        contentItem: ColumnLayout {
            spacing: 16
            
            RowLayout {
                spacing: 10
                Image {
                    source: "qrc:/icons/shield.svg"
                    sourceSize: Qt.size(22, 22)
                }
                Text {
                    text: "Yedek Dosyası Doğrulandı"
                    color: textMain
                    font.pixelSize: 18
                    font.bold: true
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 64
                radius: 6
                color: bgSecondary
                border.color: borderMain
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4
                    Text {
                        text: "Kayıt Sayısı: " + (pendingRestoreInfo ? pendingRestoreInfo.entryCount : 0) + " adet şifre"
                        color: textMain
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Text {
                        text: "Oluşturulma: " + (pendingRestoreInfo ? pendingRestoreInfo.createdAt : "")
                        color: textMuted
                        font.pixelSize: 12
                    }
                }
            }
            
            Text {
                text: (pendingRestoreInfo && pendingRestoreInfo.canMerge && appState === 2) ?
                      "Tam Geri Yükleme mevcut kasayı bu yedekle yeniler.\nBirleştirme ise mevcut şifrelerinizi koruyarak yeni şifreleri ekler." :
                      "Tam Geri Yükleme yapıldığında mevcut veritabanı silinir ve bu yedek kurulur."
                color: textMuted
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    text: "İptal"
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: 80
                    background: Rectangle { color: "transparent"; radius: 4; border.color: borderMain; border.width: 1 }
                    contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: restoreConfirmDialog.close()
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    visible: pendingRestoreInfo && pendingRestoreInfo.canMerge && appState === 2
                    text: "Birleştir (Ekle)"
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: 120
                    background: Rectangle { color: bgHover; radius: 4; border.color: borderMain }
                    contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (vaultManager.restoreVaultBackup(pendingRestoreFile, true)) {
                            restoreConfirmDialog.close()
                            loadData()
                            showToast("Yedekteki şifreler mevcut kasaya başarıyla eklendi.")
                        } else {
                            showToast("Birleştirme işlemi başarısız oldu!")
                        }
                    }
                }
                
                Button {
                    text: "Tam Geri Yükle"
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: 130
                    background: Rectangle { color: accent; radius: 4 }
                    contentItem: Text { text: parent.text; color: bgMain; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (vaultManager.restoreVaultBackup(pendingRestoreFile, false)) {
                            restoreConfirmDialog.close()
                            appState = 1
                            showToast("Kasa başarıyla geri yüklendi. Giriş yapabilirsiniz.")
                        } else {
                            showToast("Geri yükleme işlemi başarısız oldu!")
                        }
                    }
                }
            }
        }
    }
    
    // Başlangıç Dil Seçim Ekranı (İlk Açılışta veya Ayarlardan Çağrılabilir)
    Dialog {
        id: welcomeLanguageDialog
        anchors.centerIn: parent
        width: Math.min(520, parent.width - 40)
        modal: true
        closePolicy: Popup.NoAutoClose
        dim: true
        parent: Overlay.overlay
        
        background: Rectangle {
            color: "#0f0f0f"
            radius: 16
            border.color: "#2a2a2a"
            border.width: 1
            
            // Soft gradient glow accent on top
            Rectangle {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: "#ffffff" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
        
        contentItem: ColumnLayout {
            spacing: 20
            
            // Header with Shield Icon & Title
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 12
                spacing: 10
                
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 54
                    height: 54
                    radius: 27
                    color: "#161616"
                    border.color: "#333333"
                    border.width: 1
                    
                    Image {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        source: "qrc:/icons/shield.svg"
                    }
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "VoidPass"
                    color: textMain
                    font.pixelSize: 22
                    font.bold: true
                    font.letterSpacing: 2
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Hoş Geldiniz • Welcome"
                    color: textMain
                    font.pixelSize: 15
                    font.bold: true
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Lütfen kullanmak istediğiniz dili seçin\nPlease choose your preferred language"
                    color: textMuted
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            // 2 Büyük Yuvarlak Bayrak Seçim Kartı
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                spacing: 16
                
                // Türkçe Kartı
                Rectangle {
                    id: trCard
                    Layout.fillWidth: true
                    height: 140
                    radius: 12
                    color: trMouse.hovered ? "#181818" : "#121212"
                    border.color: trMouse.hovered ? "#ffffff" : "#282828"
                    border.width: trMouse.hovered ? 2 : 1
                    scale: trMouse.pressed ? 0.98 : (trMouse.hovered ? 1.02 : 1.0)
                    
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        // Yuvarlak Türk Bayrağı
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 58
                            height: 58
                            radius: 29
                            color: "transparent"
                            clip: true
                            border.color: trMouse.hovered ? "#e30a17" : "#444444"
                            border.width: 2
                            
                            Image {
                                anchors.fill: parent
                                source: "qrc:/icons/flag_tr.svg"
                                sourceSize: Qt.size(58, 58)
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Türkçe"
                            color: textMain
                            font.pixelSize: 15
                            font.bold: true
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Türkiye"
                            color: textMuted
                            font.pixelSize: 11
                        }
                    }
                    
                    MouseArea {
                        id: trMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            appLang = "tr"
                            vaultManager.setLanguage("tr")
                            welcomeLanguageDialog.close()
                            showToast("Dil Türkçe olarak ayarlandı.")
                        }
                    }
                }
                
                // English Card
                Rectangle {
                    id: enCard
                    Layout.fillWidth: true
                    height: 140
                    radius: 12
                    color: enMouse.hovered ? "#181818" : "#121212"
                    border.color: enMouse.hovered ? "#ffffff" : "#282828"
                    border.width: enMouse.hovered ? 2 : 1
                    scale: enMouse.pressed ? 0.98 : (enMouse.hovered ? 1.02 : 1.0)
                    
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        // Yuvarlak Amerikan Bayrağı
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 58
                            height: 58
                            radius: 29
                            color: "transparent"
                            clip: true
                            border.color: enMouse.hovered ? "#0052b4" : "#444444"
                            border.width: 2
                            
                            Image {
                                anchors.fill: parent
                                source: "qrc:/icons/flag_us.svg"
                                sourceSize: Qt.size(58, 58)
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "English"
                            color: textMain
                            font.pixelSize: 15
                            font.bold: true
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "United States"
                            color: textMuted
                            font.pixelSize: 11
                        }
                    }
                    
                    MouseArea {
                        id: enMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            appLang = "en"
                            vaultManager.setLanguage("en")
                            welcomeLanguageDialog.close()
                            showToast("Language set to English.")
                        }
                    }
                }
            }
            
            Item { height: 10 }
        }
    }

    // Modern Glassmorphic Toast Notification
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: toastVisible ? 24 : -60
        scale: uiScale
        transformOrigin: Item.Bottom
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

    Component.onCompleted: {
        if (!vaultManager.hasSelectedLanguage()) {
            welcomeLanguageDialog.open()
        }
    }
}
