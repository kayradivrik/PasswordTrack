# PasswordTrack 🛡️

Modern, minimalist ve **Zero-Knowledge (Sıfır Bilgi)** mimarisine sahip C++ / Qt6 masaüstü parola yöneticisi.

---

## ✨ Özellikler

* **Zero-Knowledge Mimarisi:** Tüm şifreleme ve çözme işlemleri tamamen istemci tarafında (yerel cihazınızda) gerçekleşir. Ana parolanız asla kaydedilmez.
* **Askeri Düzeyde Şifreleme:** AES-256-GCM ve PBKDF2-HMAC-SHA256 (100.000 iterasyon) ile koruma.
* **Parola Sağlığı Paneli:**
  * Kasa genel güvenlik skoru (%0 - %100).
  * Zayıf, tekrar eden (reused) ve veri sızıntılarına (HIBP) karışmış parolaları anında tespit etme ve tek tıkla filtreleme.
* **Pano Güvenliği (Clipboard Clearance):** Kopyalanan parolalar panoda açık kalmaz; 30 saniye sonra otomatik olarak hafızadan temizlenir.
* **Şifre Düzenleme (Edit):** Mevcut kayıtları silmeden doğrudan güncelleme imkanı.
* **Otomatik Kilit (Auto-Lock):** Belirlenen süre boyunca (1 dk, 5 dk, 10 dk) fare ve klavye hareketsizliği algılandığında kasanın RAM'deki şifreleme anahtarlarını anında sıfırlayarak kilit ekranına dönmesi.
* **Anti-Screenshot Koruması (Windows):** OBS, Snipping Tool veya ekran yakalama yazılımlarından pencere içeriğini siyah ekran olarak koruma (`WDA_EXCLUDEFROMCAPTURE`).
* **Veri Dışa Aktarma (CSV):** Şifreleri Excel ile tam uyumlu UTF-8 BOM CSV formatında dışa aktarma.
* **Özelleştirilebilir Duvar Kağıdı:** Ayarlanabilir opaklık ve akıllı Vignette (karartma) filtresi ile her zaman okunabilir tasarım.

---

## 🐧 Arch Linux Kurulum ve Derleme Rehberi

Uygulama tam platformlar arası (cross-platform) olarak geliştirilmiştir. Arch Linux üzerinde derlemek için:

### 1. Gerekli Bağımlılıkları Yükleyin
```bash
sudo pacman -S base-devel cmake git qt6-base qt6-declarative qt6-svg openssl sqlite
```

### 2. Depoyu Klonlayın ve Derleyin
```bash
git clone https://github.com/kayradivrik/PasswordTrack.git
cd PasswordTrack
cmake -B build -S .
cmake --build build -j$(nproc)
```

### 3. Çalıştırın
```bash
./build/VaultApp
```

---

## 🪟 Windows (MSYS2 / MinGW) ile Derleme

```powershell
cmake -B build -S .
cmake --build build --config Release
.\build\VaultApp.exe
```

---

## 🔒 Güvenlik Mimarisi

* **Şifreleme:** AES-256-GCM (12-byte IV, 16-byte Authentication Tag)
* **Anahtar Türetme (KDF):** PBKDF2-HMAC-SHA256 (100.000 döngü, 16-byte Salt)
* **Sızıntı Taraması:** Have I Been Pwned API v3 (k-Anonymity modeli; şifrenin yalnızca SHA-1 hash'inin ilk 5 karakteri sorgulanır, tam hash veya şifre asla ağa iletilmez).
