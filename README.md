# VoidPass - Modern & Secure Local Password Manager

VoidPass, modern bir arayüz ile güçlü şifreleme algoritmalarını bir araya getiren, tamamen yerel olarak çalışan (offline-first) bir parola yöneticisidir. Tüm şifreleriniz C++ arka planında **AES-256-GCM** kullanılarak şifrelenir ve kullanıcı odaklı şık bir QML arayüzü ile yönetilir.

## 🚀 Özellikler

### Güvenlik & Şifreleme
- **AES-256-GCM Şifreleme:** Kasanızdaki tüm parolalar kırılması imkansız AES-256 algoritmasıyla şifrelenir.
- **Ekran Alıntısı Koruması (Anti-Screenshot):** Yalnızca Windows'a özel Windows API (WDA_EXCLUDEFROMCAPTURE) entegrasyonu sayesinde, OBS, Snipping Tool veya zararlı yazılımların arayüzün kaydını alması engellenir. Ekran kaydında uygulama simsiyah görünür.
- **Otomatik Kilit (Auto-Lock):** Kasa açıkken belirli bir süre boyunca hiçbir etkileşimde bulunulmazsa, güvenlik için uygulama otomatik olarak kilitlenir.
- **Pano Güvenliği:** Panoya (Clipboard) kopyaladığınız parolalar, başka uygulamaların veya kişilerin görmemesi için 30 saniye sonra sistem tarafından otomatik olarak silinir.
- **Atomik İşlemler (Transactions):** Ana parola değiştirilirken veritabanı bozulmalarına karşı koruma mekanizması.

### Veri Yönetimi & Kasa Sağlığı
- **Güvenlik Rozetleri (Health Score):** Eklediğiniz şifreler gerçek zamanlı olarak analiz edilir. 
  - **Zayıf Şifre:** Kısa veya tahmin edilebilir parolalar.
  - **Tekrar Eden Şifre:** Aynı şifrenin farklı platformlarda kullanımı.
  - Sızdırılmış şifre risklerine karşı rozet bildirimleri ve genel "Kasa Sağlığı" skor tablosu (100 üzerinden ağırlıklı cezalandırma sistemi).
- **Yedekleme ve Geri Yükleme (.vault):** Kasanızı AES-256 ile şifreli `.vault` uzantılı kendi formatımda dışa aktarabilir ve sonrasında mevcut kasanıza "merge (birleştirme)" mantığıyla geri yükleyebilirsiniz.
- **CSV Desteği:** İhtiyaç durumunda verilerinizi Excel uyumlu (UTF-8 BOM) CSV olarak dışa aktarabilirsiniz.
- **Gelişmiş Rastgele Parola Üretici:** Yeni şifre eklerken uzunluğunu (8-64 karakter) esnekçe ayarlayıp güvenli parolalar türetebilirsiniz.

### Arayüz (UI/UX)
- **Modern QML Mimarisi:** Native hissettiren, akıcı 60FPS arayüz. Glassmorphism (buzlu cam) efektleriyle desteklenen şık bileşenler.
- **Pencereye Duyarlı Esnek Düzen (Responsive Layout):** Matematiksel formüllerle yazılmış dinamik tablo düzeni. Pencere boyutu değiştiğinde tablolar ve menüler esner, daraltılır ve asla taşma veya bozulma (Jitter) yaşanmaz.
- **Akıllı Marka Tanıma (Brand Detection):** Eklediğiniz servisin adından (örn. "gmail", "netflix") otomatik olarak ikonları algılayan ve gösteren 50'den fazla yerleşik marka kataloğu.
- **Kişiselleştirme:** Arayüzün arka planına özel duvar kağıdı yükleyebilir ve okunabilirliği koruyan dinamik karartma (Vignette) filtresini kullanabilirsiniz. Ölçek (UI Scale) ve tam çift dil (Türkçe/İngilizce) desteği.
- **Özel Animasyonlar:** Butonlara özel geri sekme animasyonları (OutBack), renk geçişleri ve özel tasarım kaydırma çubukları (Custom Scrollbar).

## 🛠️ Teknik Detaylar (Tech Stack)
- **Dil:** C++17, QML, JavaScript
- **Framework:** Qt 6.x
- **Veritabanı/Depolama:** Yerel JSON / Binary Serializer (AES Şifreli)
- **Mimari:** Frontend-Backend Ayrımı (C++ backend özellikleri QML'e ContextProperty olarak hook edilir). 

## ⚙️ Kurulum ve Derleme
Bu projeyi derlemek için sisteminizde Qt 6 (tercihen 6.6+) kurulu olmalıdır.
CMake ile konfigüre edip `main.cpp` üzerinden çalıştırabilirsiniz.

## 👨‍💻 Geliştirici
Bu proje, modern bir C++ ve Qt/QML altyapısının pratikte ne kadar estetik ve aynı zamanda ne kadar yüksek güvenlik standartlarıyla harmanlanabileceğini göstermek amacıyla bir portföy projesi olarak geliştirilmiştir.
