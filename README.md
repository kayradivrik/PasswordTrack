<div align="center">
  <img src="icons/logo.png" alt="VoidPass Logo" width="120" />
  <h1>VoidPass</h1>
  <p><strong>A Highly Secure, Local-First, Zero-Knowledge Password Manager</strong><br>
  <strong>Yüksek Güvenlikli, Yerel, Sıfır Bilgi Tabanlı Parola Yöneticisi</strong></p>

  <p>
    <img src="https://img.shields.io/badge/C%2B%2B-17-blue.svg" alt="C++17" />
    <img src="https://img.shields.io/badge/Qt-6.0%2B-41CD52.svg" alt="Qt6" />
    <img src="https://img.shields.io/badge/OpenSSL-3.0-721412.svg" alt="OpenSSL" />
    <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-lightgrey.svg" alt="Platforms" />
  </p>
  
  [English](#english) | [Türkçe](#turkce)
</div>

---

<h2 id="english">🇬🇧 English</h2>

## 📌 Overview

**VoidPass** is a modern, privacy-focused offline password manager built from the ground up with C++ and Qt Quick (QML). Designed for developers and privacy enthusiasts, VoidPass guarantees that your sensitive data never leaves your device unencrypted. 

Unlike cloud-based password managers, VoidPass embraces a **Zero-Knowledge Architecture**. Metadata such as service names, usernames, and URLs are grouped into a single JSON blob and encrypted collectively, leaving no trace for malicious actors who might obtain the database file.

## 🚀 Enterprise-Grade Security

- **AES-256-GCM Encryption:** All payloads are encrypted using military-grade AES-256 in Galois/Counter Mode.
- **Brute-Force Resistance:** Master keys are derived using **PBKDF2-HMAC-SHA256** with **600,000 iterations**.
- **Advanced RAM / Memory Protection:** 
  - To prevent Cold Boot and RAM scraping attacks, encryption keys are pinned to physical RAM.
  - Keys are strictly prevented from being swapped to the disk pagefile.
  - Memory is securely zeroed out immediately upon locking the vault.
- **Zero-Knowledge Storage:** The SQLite database stores only unidentifiable IDs and encrypted blobs. No metadata is leaked.

## ✨ Key Features

- **Modern & Responsive UI:** A sleek, monochrome interface built with Qt Quick.
- **Data Breach Scanner:** Built-in integration with *Have I Been Pwned* using the `k-anonymity` model. 
- **Browser Autofill Integration:** Local HTTP/TCP server securely bridges your desktop vault with the extension.
- **Built-in 2FA (TOTP):** Generate Time-based One-Time Passwords directly inside the app.
- **Emergency Kit Generator:** Export a printable HTML/PDF document containing your vault recovery details.
- **Advanced Password Generator:** Cryptographically Secure Pseudo-Random Number Generator (CSPRNG).
- **Import/Export:** Seamlessly migrate from other managers via CSV, or create AES-256 encrypted backups.

## 🛠️ Technology Stack

- **Backend:** C++17
- **Frontend / UI:** Qt 6 (QML, Qt Quick Controls)
- **Cryptography:** OpenSSL (libcrypto)
- **Database:** SQLite3 (via QtSql)

## 📦 Build Instructions

### Prerequisites
- CMake 3.16+
- Qt 6 (Core, Gui, Quick, Qml, Sql, Network, Concurrent)
- OpenSSL (libcrypto)
- A C++17 compatible compiler (GCC, Clang, MSVC)

```bash
git clone https://github.com/yourusername/VoidPass.git
cd VoidPass
mkdir build && cd build
cmake .. -G Ninja
ninja
./VoidPass
```

---

<h2 id="turkce">🇹🇷 Türkçe</h2>

## 📌 Genel Bakış

**VoidPass**, C++ ve Qt Quick (QML) ile sıfırdan geliştirilmiş, modern, gizlilik odaklı ve tamamen çevrimdışı (offline) çalışan bir parola yöneticisidir. Geliştiriciler ve gizliliğine önem verenler için tasarlanmış olan VoidPass, hassas verilerinizin cihazınızdan hiçbir zaman şifrelenmemiş şekilde çıkmayacağını garanti eder.

VoidPass, **Sıfır Bilgi Mimarisi (Zero-Knowledge Architecture)** kullanır. Hizmet adları, kullanıcı adları ve URL'ler gibi tüm meta veriler şifrelenir ve veritabanı dosyasını ele geçiren kötü niyetli kişilere hiçbir iz bırakmaz.

## 🚀 Kurumsal Seviye Güvenlik

- **AES-256-GCM Şifreleme:** Tüm verileriniz askeri düzeyde AES-256 algoritmasıyla şifrelenir.
- **Kaba Kuvvet (Brute-Force) Koruması:** Ana anahtarlar **600.000 iterasyonlu PBKDF2-HMAC-SHA256** ile oluşturulur.
- **Gelişmiş RAM / Bellek Koruması:** Şifreleme anahtarları işletim sistemi API'leri ile fiziksel RAM'e kilitlenir ve diske (pagefile) sızması engellenir. Kasa kilitlendiğinde bellek anında temizlenir.
- **Sıfır Bilgi Depolama:** SQLite veritabanı yalnızca şifrelenmiş içerikleri ve anonim ID'leri saklar.

## ✨ Temel Özellikler

- **Modern ve Duyarlı Arayüz:** Qt Quick ile hazırlanmış şık, monokrom tasarım.
- **Veri İhlali Tarayıcısı:** Şifrelerinizin sızdırılıp sızdırılmadığını `k-anonymity` modeli ile güvenli şekilde kontrol edin.
- **Tarayıcı Otomatik Doldurma:** Masaüstü uygulamanız ile tarayıcı eklentisi arasında güvenli bir köprü.
- **Dahili 2FA (TOTP):** Doğrudan uygulama içinden zaman tabanlı tek kullanımlık şifreler üretin.
- **Acil Durum Kiti:** Kasa kurtarma detaylarınızı içeren yazdırılabilir bir HTML/PDF belgesi dışa aktarın.
- **Gelişmiş Şifre Üretici:** Kriptografik olarak güvenli sözde rastgele sayı üreteci (CSPRNG).
- **İçe/Dışa Aktarma:** Bitwarden, Chrome veya Firefox'tan CSV ile kolayca geçiş yapın.

## 🔒 Lisans
Bu proje MIT Lisansı altında lisanslanmıştır - daha fazla bilgi için [LICENSE](LICENSE) dosyasına bakın.
