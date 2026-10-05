import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs
import "components"
import "views"

ApplicationWindow {
    visible: true
    width: 960
    height: 620
    minimumWidth: 780
    minimumHeight: 480
    title: "VoidPass"
    color: bgMain
    font.family: "Segoe UI"
    font.pixelSize: 13

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
            add_password_btn: "Yeni Şifre Ekle",
            passwords_title: "Parolalarım",
            cat_all: "Tümü",
            cat_favorite: "Favoriler",
            cat_general: "Genel",
            cat_work: "İş",
            cat_finance: "Finans",
            cat_social: "Sosyal",
            cat_personal: "Kişisel",
            
            health_score: "Kasa Sağlığı",
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
            settings_pwd_title: "Ana Parolayı Değiştir",
            settings_pwd_btn: "Değiştir...",
            settings_csv_btn: "Dışa Aktar...",
            settings_backup_title: "Şifreli Yedek (.vault)",
            history_title: "Parola Geçmişi",
            history_empty: "Bu kayıt için eski parola bulunmuyor.",
            
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
            add_password_btn: "Add Password",
            passwords_title: "My Passwords",
            cat_all: "All",
            cat_favorite: "Favorites",
            cat_general: "General",
            cat_work: "Work",
            cat_finance: "Finance",
            cat_social: "Social",
            cat_personal: "Personal",
            
            health_score: "Vault Health",
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
            settings_pwd_title: "Change Master Password",
            settings_pwd_btn: "Change...",
            settings_csv_btn: "Export...",
            settings_backup_title: "Encrypted Backup (.vault)",
            history_title: "Password History",
            history_empty: "No previous passwords for this entry.",
            
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

    // Pencere genişliğine duyarlı, dinamik tablo kolon genişliği algoritmam.
    readonly property real currentScaledWidth: width / uiScale
    readonly property int dashboardMargin: currentScaledWidth < 900 ? 20 : 32
    readonly property int dashboardWidth: Math.max(100, Math.round(currentScaledWidth - (dashboardMargin * 2)))
    readonly property int tableAvailableWidth: Math.max(10, dashboardWidth - 32 - 176)
    readonly property int colServiceWidth: Math.max(100, Math.floor(tableAvailableWidth * 0.28))
    readonly property int colUsernameWidth: Math.max(120, Math.floor(tableAvailableWidth * 0.38))
    readonly property int colPasswordWidth: Math.max(100, tableAvailableWidth - colServiceWidth - colUsernameWidth)
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
    
    // Otomatik ikon tanımlaması için oluşturduğum yerleşik marka sözlüğü.
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
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
    
    // Arka plan resmi üzerindeki okunabilirliği artırmak için Karartma efekti ekliyorum.
    Rectangle {
        anchors.fill: parent
        visible: wallpaperPath !== "" // Sadece duvar kağıdı varken çalışır
        z: -1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e6000000" } // %90 Siyah
            GradientStop { position: 0.25; color: "#b3000000" } // %70 Siyah
            GradientStop { position: 0.75; color: "#b3000000" } // %70 Siyah
            GradientStop { position: 1.0; color: "#e6000000" } // %90 Siyah
        }
    }
    
    FileDialog {
        id: wallpaperDialog
        title: "Arka Plan Seç"
        nameFilters: ["Resim Dosyaları (*.png *.jpg *.jpeg)"]
        onAccepted: {
            wallpaperPath = selectedFile
            vaultManager.setWallpaper(selectedFile)
            if (wallpaperOpacity > 0.80 || wallpaperOpacity <= 0.0) {
                wallpaperOpacity = 0.20
                vaultManager.setWallpaperOpacity(0.20)
            }
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

    ListModel {
        id: vaultModel
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
        x: 0
        y: 0
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
                source: "qrc:/icons/logo.png"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                fillMode: Image.PreserveAspectFit
                mipmap: true
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
                padding: 0
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
                padding: 0
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
                source: "qrc:/icons/logo.png"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                fillMode: Image.PreserveAspectFit
                mipmap: true
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
                property bool busy: false
                text: busy ? "Doğrulanıyor..." : "Kilidi Aç"
                enabled: !busy
                padding: 0
                Layout.preferredWidth: 320
                Layout.preferredHeight: 48
                contentItem: Item {
                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Item {
                            visible: unlockBtn.busy
                            width: 18; height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                anchors.fill: parent
                                radius: 9
                                color: "transparent"
                                border.width: 2
                                border.color: "#33000000"
                            }
                            Rectangle {
                                width: 6; height: 6; radius: 3
                                color: bgMain
                                x: 6; y: -3
                            }
                            RotationAnimator on rotation {
                                running: unlockBtn.busy
                                from: 0; to: 360; duration: 800
                                loops: Animation.Infinite
                            }
                        }
                        Text {
                            text: unlockBtn.text
                            color: bgMain
                            font.bold: true
                            font.pixelSize: 15
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                background: Rectangle {
                    color: parent.down ? "#cccccc" : (parent.hovered ? accentHover : accent)
                    opacity: unlockBtn.busy ? 0.8 : 1.0
                    radius: 4
                }
                onClicked: {
                    busy = true
                    vaultManager.unlockVaultAsync(unlockPwd.text)
                }
            }

            Connections {
                target: vaultManager
                function onUnlockCompleted(success, errorMsg) {
                    unlockBtn.busy = false
                    unlockPwd.text = ""
                    if (success) {
                        appState = 2
                        loadData()
                    } else {
                        unlockPwd.placeholderText = "Hatalı parola! Tekrar dene."
                    }
                }
            }
        }
    }
    

        // Dashboard View (Modular)
        DashboardView {
            id: dashboardView
            visible: appState === 2
        }

        // Settings View (Modular)
        SettingsView {
            id: settingsView
            visible: appState === 3
        }
    } // End of scaledContent

    // Add Password Dialog (Modular)
    AddPasswordDialog {
        id: addDialog
    }

    // Edit Password Dialog (Modular)
    EditPasswordDialog {
        id: editDialog
    }

    // Password History Dialog (Modular)
    PasswordHistoryDialog {
        id: historyDialog
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
                        padding: 0
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
                        color: score <= 1 ? danger : (score <= 2 ? "#e5e5e5" : (score <= 3 ? "#f2f2f2" : "#ffffff"))
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
                    padding: 0
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 100
                    background: Rectangle { color: "transparent"; radius: 4; border.color: borderMain; border.width: 1 }
                    contentItem: Text { text: parent.text; color: textMain; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: changeMasterPwdDialog.close()
                }
                Button {
                    text: "Parolayı Güncelle"
                    padding: 0
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
                    padding: 0
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
                    padding: 0
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
                    padding: 0
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
                    width: 68
                    height: 68
                    radius: 34
                    color: "#161616"
                    border.color: "#333333"
                    border.width: 1
                    
                    Image {
                        anchors.centerIn: parent
                        width: 44
                        height: 44
                        source: "qrc:/icons/logo.png"
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
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
                source: "qrc:/icons/logo.png"
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                sourceSize: Qt.size(36, 36)
                fillMode: Image.PreserveAspectFit
                mipmap: true
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
        var leakedSet = vaultManager.getLeakedIds()

        var entries = vaultManager.getAllEntries()
        
        var sortIdx = (dashboardView && dashboardView.sortCombo) ? dashboardView.sortCombo.currentIndex : 0
        entries.sort(function(a, b) {
            var sa = a.service || ""
            var sb = b.service || ""
            if (sortIdx === 0) return b.id - a.id;
            if (sortIdx === 1) return a.id - b.id;
            if (sortIdx === 2) return sa.localeCompare(sb);
            if (sortIdx === 3) return sb.localeCompare(sa);
            return 0;
        });
        
        var q = (dashboardView && dashboardView.searchInput) ? dashboardView.searchInput.text.toLowerCase() : ""
        var selCat = (dashboardView && dashboardView.selectedCategory) ? dashboardView.selectedCategory : "all"

        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i]
            var sLower = (entry.service || "").toLowerCase()
            var uLower = (entry.username || "").toLowerCase()
            var matchesSearch = (q === "" || sLower.indexOf(q) !== -1 || uLower.indexOf(q) !== -1)
            if (!matchesSearch) continue;

            // Kategori ve Favori filtreleri
            if (selCat === "favorite") {
                if (!entry.isFavorite) continue;
            } else if (selCat !== "all") {
                if (entry.category !== selCat) continue;
            }

            entry.isWeak = (weakSet.indexOf(entry.id) !== -1)
            entry.isReused = (reusedSet.indexOf(entry.id) !== -1)
            entry.isPwned = (leakedSet.indexOf(entry.id) !== -1)

            // Sağlık filtre kontrolü
            if (healthFilter === "weak" && !entry.isWeak) continue;
            if (healthFilter === "reused" && !entry.isReused) continue;
            if (healthFilter === "pwned" && !entry.isPwned) continue;

            vaultModel.append(entry)
        }
        pwnedCount = leakedSet.length
    }

    Component.onCompleted: {
        if (!vaultManager.hasSelectedLanguage()) {
            welcomeLanguageDialog.open()
        }
    }
}
