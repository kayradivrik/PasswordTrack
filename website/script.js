const translations = {
    en: {
        nav_features: "Features",
        badge_text: "v1.0.0 Stable Release",
        hero_title: "Absolute Security.<br><span class='highlight'>Zero Compromise.</span>",
        hero_desc: "An offline-first, zero-knowledge password manager protected by AES-256-GCM encryption and anti-screenshot technology.",
        btn_download: "Download for Windows",
        btn_subtext: "Portable ZIP • 64-bit",
        btn_features: "Explore Features",
        feat_title: "Built for Paranoia.",
        feat_desc: "We removed the cloud to eliminate the risk. Your vault is completely isolated and cryptographically locked.",
        c1_title: "Military-Grade Encryption",
        c1_desc: "Your vault is secured locally using AES-256-GCM authenticated encryption. Without your Master Password, your data is mathematically impossible to read or manipulate.",
        c2_title: "Anti-Screenshot",
        c2_desc: "Advanced Windows API integration completely blinds screen recorders, snipping tools, and spyware.",
        c3_title: "Offline-First",
        c3_desc: "Zero telemetry. Zero cloud sync. Your data never leaves your computer.",
        c4_title: "Vault Health",
        c4_desc: "Real-time analysis detects weak, reused, and compromised (pwned) passwords.",
        c5_title: "Modern Native UI",
        c5_desc: "Built with C++ and Qt Quick (QML) for blistering 60FPS performance. Features a fully responsive, glassmorphic dark interface.",
        footer_text: "Developed by",
        footer_subtext: "as an open-source portfolio project under MIT License."
    },
    tr: {
        nav_features: "Özellikler",
        badge_text: "v1.0.0 Kararlı Sürüm",
        hero_title: "Mutlak Güvenlik.<br><span class='highlight'>Sıfır Taviz.</span>",
        hero_desc: "AES-256-GCM şifreleme ve ekran görüntüsü engelleme teknolojisi ile korunan, tamamen çevrimdışı ve sıfır bilgi parolası yöneticisi.",
        btn_download: "Windows için İndir",
        btn_subtext: "Taşınabilir ZIP • 64-bit",
        btn_features: "Özellikleri Keşfet",
        feat_title: "Paranoyaklar İçin Üretildi.",
        feat_desc: "Riski ortadan kaldırmak için bulutu kaldırdık. Kasanız tamamen izole edilmiş ve kriptografik olarak kilitlenmiştir.",
        c1_title: "Askeri Düzeyde Şifreleme",
        c1_desc: "Kasanız yerel olarak AES-256-GCM kimlik doğrulamalı şifreleme ile güvence altına alınır. Ana Parolanız olmadan verilerinizin okunması veya manipüle edilmesi imkansızdır.",
        c2_title: "Ekran Görüntüsü Engelleme",
        c2_desc: "Gelişmiş Windows API entegrasyonu sayesinde ekran kaydedicileri, alıntı araçlarını ve casus yazılımları tamamen kör eder.",
        c3_title: "Tamamen Çevrimdışı",
        c3_desc: "Sıfır veri toplama. Sıfır bulut senkronizasyonu. Verileriniz asla bilgisayarınızdan dışarı çıkmaz.",
        c4_title: "Kasa Sağlığı",
        c4_desc: "Gerçek zamanlı analiz sayesinde zayıf, tekrar eden ve sızdırılmış (pwned) parolaları anında tespit eder.",
        c5_title: "Modern ve Yerel Arayüz",
        c5_desc: "Mükemmel 60FPS performansı için C++ ve Qt Quick (QML) ile oluşturuldu. Tamamen esnek, buzlu cam efektli karanlık bir arayüze sahiptir.",
        footer_text: "MIT Lisansı altında açık kaynaklı bir portföy projesi olarak",
        footer_subtext: "tarafından geliştirildi."
    }
};

let currentLang = 'en';

function setLanguage(lang) {
    if (currentLang === lang) return;
    currentLang = lang;
    
    // Update active button
    document.querySelectorAll('.lang-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.id === `btn-${lang}`) {
            btn.classList.add('active');
        }
    });

    // Translate DOM elements
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (translations[lang][key]) {
            // Use innerHTML instead of textContent to preserve formatting like <br> and spans
            el.innerHTML = translations[lang][key];
        }
    });

    // Special footer layout for TR grammar differences
    if (lang === 'tr') {
        // "MIT Lisansı altında... [kayradivrik] tarafından geliştirildi"
        const footerText = document.querySelector('[data-i18n="footer_text"]');
        const footerSubtext = document.querySelector('[data-i18n="footer_subtext"]');
        footerText.innerHTML = translations.tr.footer_text;
        footerSubtext.innerHTML = translations.tr.footer_subtext;
    }
}

// Fade in animation on scroll
document.addEventListener('DOMContentLoaded', () => {
    // Language Setup
    document.getElementById('btn-en').addEventListener('click', () => setLanguage('en'));
    document.getElementById('btn-tr').addEventListener('click', () => setLanguage('tr'));

    // Intersection Observer
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
    };

    const observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    document.querySelectorAll('.fade-in-up').forEach(element => {
        observer.observe(element);
    });

    // Initial trigger for elements already in view
    setTimeout(() => {
        document.querySelectorAll('.fade-in-up').forEach(element => {
            const rect = element.getBoundingClientRect();
            if (rect.top < window.innerHeight) {
                element.classList.add('visible');
            }
        });
    }, 100);

    // 3D Tilt Effect for Bento Cards
    const cards = document.querySelectorAll('.hover-tilt');
    
    cards.forEach(card => {
        card.addEventListener('mousemove', e => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = ((y - centerY) / centerY) * -5;
            const rotateY = ((x - centerX) / centerX) * 5;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
            card.style.transition = 'none';
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = `perspective(1000px) rotateX(0deg) rotateY(0deg) scale3d(1, 1, 1)`;
            card.style.transition = 'all 0.4s ease';
        });
        
        card.addEventListener('mouseenter', () => {
            card.style.transition = 'all 0.1s ease';
        });
    });
});
