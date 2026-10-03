#include "VaultManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QGuiApplication>
#include <QClipboard>
#include <QCryptographicHash>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QRegularExpression>
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <QWindow>
#include <QFile>
#include <QSettings>
#include <QUrl>
#include <QTextStream>
#include <QStringConverter>
#include <QEvent>
#ifdef Q_OS_WIN
#include <windows.h>
#endif

const int KEY_LEN = 32;
const int SALT_LEN = 16;
const int IV_LEN = 12;
const int TAG_LEN = 16;
const int PBKDF2_ITER = 100000;
const QString CANARY_TEXT = "SYSTEM_CANARY_VALID";

VaultManager::VaultManager(QObject* parent) : QObject(parent) {
    netManager = new QNetworkAccessManager(this);
    initDatabase();

    // 1. Pano Güvenliği (30 Saniye Sonra Otomatik Temizleme)
    clipboardClearTimer = new QTimer(this);
    clipboardClearTimer->setSingleShot(true);
    connect(clipboardClearTimer, &QTimer::timeout, this, [this]() {
        if (QClipboard *clipboard = QGuiApplication::clipboard()) {
            if (!lastCopiedPassword.isEmpty() && clipboard->text() == lastCopiedPassword) {
                clipboard->clear();
                lastCopiedPassword.clear();
                emit clipboardCleared();
            }
        }
    });

    // 2. Otomatik Kilit (Boşta Kalma Takibi)
    lastActivityTime = QDateTime::currentDateTime();
    if (QGuiApplication::instance()) {
        QGuiApplication::instance()->installEventFilter(this);
    }

    autoLockCheckTimer = new QTimer(this);
    connect(autoLockCheckTimer, &QTimer::timeout, this, [this]() {
        int minutes = getAutoLockMinutes();
        if (minutes > 0 && isUnlocked()) {
            qint64 elapsedSec = lastActivityTime.secsTo(QDateTime::currentDateTime());
            if (elapsedSec >= minutes * 60) {
                lockVault();
            }
        }
    });
    autoLockCheckTimer->start(1000);
}

VaultManager::~VaultManager() {
    if (db.isOpen()) db.close();
}

bool VaultManager::initDatabase() {
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("vault.db");
    if (!db.open()) return false;

    QSqlQuery query;
    query.exec("CREATE TABLE IF NOT EXISTS metadata (key TEXT PRIMARY KEY, value TEXT)");
    query.exec("CREATE TABLE IF NOT EXISTS vault (id INTEGER PRIMARY KEY AUTOINCREMENT, service TEXT, username TEXT, payload BLOB)");
    return true;
}

QByteArray VaultManager::deriveKey(const QString& password, const QByteArray& salt) {
    QByteArray key(KEY_LEN, 0);
    QByteArray pwd = password.toUtf8();
    PKCS5_PBKDF2_HMAC(pwd.constData(), pwd.length(),
                      reinterpret_cast<const unsigned char*>(salt.constData()), salt.length(),
                      PBKDF2_ITER, EVP_sha256(), KEY_LEN,
                      reinterpret_cast<unsigned char*>(key.data()));
    return key;
}

QByteArray VaultManager::encryptData(const QByteArray& plaintext, const QByteArray& key) {
    QByteArray iv(IV_LEN, 0);
    RAND_bytes(reinterpret_cast<unsigned char*>(iv.data()), IV_LEN);
    
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    int len, ciphertext_len;
    QByteArray ciphertext(plaintext.length() + EVP_MAX_BLOCK_LENGTH, 0);
    QByteArray tag(TAG_LEN, 0);

    EVP_EncryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, reinterpret_cast<const unsigned char*>(key.constData()), reinterpret_cast<const unsigned char*>(iv.constData()));
    EVP_EncryptUpdate(ctx, reinterpret_cast<unsigned char*>(ciphertext.data()), &len, reinterpret_cast<const unsigned char*>(plaintext.constData()), plaintext.length());
    ciphertext_len = len;
    EVP_EncryptFinal_ex(ctx, reinterpret_cast<unsigned char*>(ciphertext.data()) + len, &len);
    ciphertext_len += len;
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, TAG_LEN, tag.data());
    EVP_CIPHER_CTX_free(ctx);

    ciphertext.resize(ciphertext_len);
    return iv + tag + ciphertext;
}

QByteArray VaultManager::decryptData(const QByteArray& payload, const QByteArray& key) {
    if (payload.length() < IV_LEN + TAG_LEN) return QByteArray();

    QByteArray iv = payload.left(IV_LEN);
    QByteArray tag = payload.mid(IV_LEN, TAG_LEN);
    QByteArray ciphertext = payload.mid(IV_LEN + TAG_LEN);
    QByteArray plaintext(ciphertext.length(), 0);

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    int len, plaintext_len, ret;

    EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, reinterpret_cast<const unsigned char*>(key.constData()), reinterpret_cast<const unsigned char*>(iv.constData()));
    EVP_DecryptUpdate(ctx, reinterpret_cast<unsigned char*>(plaintext.data()), &len, reinterpret_cast<const unsigned char*>(ciphertext.constData()), ciphertext.length());
    plaintext_len = len;
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, TAG_LEN, tag.data());
    ret = EVP_DecryptFinal_ex(ctx, reinterpret_cast<unsigned char*>(plaintext.data()) + len, &len);
    EVP_CIPHER_CTX_free(ctx);

    if (ret > 0) {
        plaintext_len += len;
        plaintext.resize(plaintext_len);
        return plaintext;
    }
    return QByteArray();
}

bool VaultManager::isSetupRequired() {
    QSqlQuery query("SELECT count(*) FROM metadata WHERE key='salt'");
    if (query.next()) {
        return query.value(0).toInt() == 0;
    }
    return true;
}

bool VaultManager::setupVault(const QString& masterPassword) {
    QByteArray salt(SALT_LEN, 0);
    RAND_bytes(reinterpret_cast<unsigned char*>(salt.data()), SALT_LEN);
    
    QByteArray key = deriveKey(masterPassword, salt);
    QByteArray encryptedCanary = encryptData(CANARY_TEXT.toUtf8(), key);

    QSqlQuery query;
    query.prepare("INSERT OR REPLACE INTO metadata (key, value) VALUES ('salt', :salt), ('canary', :canary)");
    query.bindValue(":salt", salt.toBase64());
    query.bindValue(":canary", encryptedCanary.toBase64());
    
    if (query.exec()) {
        encryptionKey = key;
        lastActivityTime = QDateTime::currentDateTime();
        return true;
    }
    return false;
}

bool VaultManager::unlockVault(const QString& masterPassword) {
    QSqlQuery query("SELECT value FROM metadata WHERE key='salt'");
    if (!query.next()) return false;
    QByteArray salt = QByteArray::fromBase64(query.value(0).toByteArray());

    query.exec("SELECT value FROM metadata WHERE key='canary'");
    if (!query.next()) return false;
    QByteArray encryptedCanary = QByteArray::fromBase64(query.value(0).toByteArray());

    QByteArray key = deriveKey(masterPassword, salt);
    QByteArray decryptedCanary = decryptData(encryptedCanary, key);

    if (decryptedCanary == CANARY_TEXT.toUtf8()) {
        encryptionKey = key;
        lastActivityTime = QDateTime::currentDateTime();
        return true;
    }
    return false;
}

void VaultManager::lockVault() {
    encryptionKey.clear();
    emit vaultLocked();
}

bool VaultManager::isUnlocked() const {
    return !encryptionKey.isEmpty();
}

bool VaultManager::eventFilter(QObject *obj, QEvent *event) {
    switch (event->type()) {
        case QEvent::MouseMove:
        case QEvent::MouseButtonPress:
        case QEvent::MouseButtonRelease:
        case QEvent::KeyPress:
        case QEvent::KeyRelease:
        case QEvent::Wheel:
        case QEvent::TouchBegin:
        case QEvent::TouchUpdate:
        case QEvent::TouchEnd:
            lastActivityTime = QDateTime::currentDateTime();
            break;
        default:
            break;
    }
    return QObject::eventFilter(obj, event);
}

QVariantList VaultManager::getAllEntries() {
    QVariantList entries;
    if (encryptionKey.isEmpty()) return entries;

    QSqlQuery query("SELECT id, service, username, payload FROM vault");
    while (query.next()) {
        QVariantMap entry;
        entry["id"] = query.value(0).toInt();
        entry["service"] = query.value(1).toString();
        entry["username"] = query.value(2).toString();
        
        QByteArray payload = query.value(3).toByteArray();
        QByteArray decryptedPwd = decryptData(payload, encryptionKey);
        entry["password"] = QString::fromUtf8(decryptedPwd);
        
        entries.append(entry);
    }
    return entries;
}

bool VaultManager::addEntry(const QString& service, const QString& username, const QString& password) {
    if (encryptionKey.isEmpty()) return false;
    QByteArray payload = encryptData(password.toUtf8(), encryptionKey);
    
    QSqlQuery query;
    query.prepare("INSERT INTO vault (service, username, payload) VALUES (:s, :u, :p)");
    query.bindValue(":s", service);
    query.bindValue(":u", username);
    query.bindValue(":p", payload);
    return query.exec();
}

bool VaultManager::updateEntry(int id, const QString& service, const QString& username, const QString& password) {
    if (encryptionKey.isEmpty()) return false;
    QByteArray payload = encryptData(password.toUtf8(), encryptionKey);

    QSqlQuery query;
    query.prepare("UPDATE vault SET service = :s, username = :u, payload = :p WHERE id = :id");
    query.bindValue(":s", service);
    query.bindValue(":u", username);
    query.bindValue(":p", payload);
    query.bindValue(":id", id);
    return query.exec();
}

bool VaultManager::deleteEntry(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM vault WHERE id = :id");
    query.bindValue(":id", id);
    return query.exec();
}

void VaultManager::copyToClipboard(const QString& text) {
    if (QClipboard *clipboard = QGuiApplication::clipboard()) {
        lastCopiedPassword = text;
        clipboard->setText(text);
        clipboardClearTimer->start(30000); // 30 saniye sonra panoyu temizle
        emit clipboardCopied(30);
    }
}

int VaultManager::checkPasswordStrength(const QString& password) {
    int score = 0;
    if (password.length() >= 8) score++;
    if (password.length() >= 12) score++;
    if (password.contains(QRegularExpression("[A-Z]"))) score++;
    if (password.contains(QRegularExpression("[0-9]"))) score++;
    if (password.contains(QRegularExpression("[^a-zA-Z0-9]"))) score++;
    if (score > 4) score = 4;
    return score;
}

void VaultManager::checkPwnedAsync(int id, const QString& plainPassword) {
    QByteArray hash = QCryptographicHash::hash(plainPassword.toUtf8(), QCryptographicHash::Sha1).toHex().toUpper();
    QString prefix = hash.left(5);
    QString suffix = hash.mid(5);
    
    QNetworkRequest request(QUrl("https://api.pwnedpasswords.com/range/" + prefix));
    request.setHeader(QNetworkRequest::UserAgentHeader, "VaultApp-Portfolio-Project");
    
    QNetworkReply* reply = netManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, id, suffix]() {
        if(reply->error() == QNetworkReply::NoError) {
            QString response = reply->readAll();
            bool pwned = response.contains(suffix);
            emit pwnedStatus(id, pwned);
        }
        reply->deleteLater();
    });
}

void VaultManager::setScreenshotProtection(bool enabled) {
#ifdef Q_OS_WIN
    if (QWindow* window = QGuiApplication::topLevelWindows().value(0)) {
        HWND hwnd = (HWND)window->winId();
        SetWindowDisplayAffinity(hwnd, enabled ? WDA_EXCLUDEFROMCAPTURE : WDA_NONE);
    }
#endif
}

void VaultManager::wipeVault() {
    db.close();
    QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);
    QFile::remove("vault.db");
    initDatabase();
}

QString VaultManager::getWallpaper() {
    QSettings settings;
    return settings.value("wallpaper", "").toString();
}

void VaultManager::setWallpaper(const QString& path) {
    QSettings settings;
    settings.setValue("wallpaper", path);
}

qreal VaultManager::getWallpaperOpacity() {
    QSettings settings;
    return settings.value("wallpaperOpacity", 0.10).toReal();
}

void VaultManager::setWallpaperOpacity(qreal opacity) {
    QSettings settings;
    settings.setValue("wallpaperOpacity", opacity);
}

bool VaultManager::exportToCSV(const QString& filePath) {
    if (encryptionKey.isEmpty()) return false;

    QString localPath = filePath;
    if (localPath.startsWith("file:///")) {
        localPath = QUrl(localPath).toLocalFile();
    } else if (localPath.startsWith("file://")) {
        localPath = QUrl(localPath).toLocalFile();
    }

    QFile file(localPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }

    QTextStream out(&file);
    // Excel ile tam uyumlu UTF-8 BOM ekliyoruz
    out.setEncoding(QStringConverter::Utf8);
    out.setGenerateByteOrderMark(true);
    out << "\"Servis\",\"Kullanıcı Adı\",\"Parola\"\n";

    QSqlQuery query("SELECT service, username, payload FROM vault ORDER BY service ASC");
    while (query.next()) {
        QString service = query.value(0).toString();
        QString username = query.value(1).toString();
        QByteArray payload = query.value(2).toByteArray();
        QString password = QString::fromUtf8(decryptData(payload, encryptionKey));

        auto escapeCsv = [](QString field) -> QString {
            field.replace("\"", "\"\"");
            return "\"" + field + "\"";
        };

        out << escapeCsv(service) << ","
            << escapeCsv(username) << ","
            << escapeCsv(password) << "\n";
    }

    file.close();
    return true;
}

int VaultManager::getAutoLockMinutes() {
    QSettings settings;
    return settings.value("autoLockMinutes", 5).toInt();
}

void VaultManager::setAutoLockMinutes(int minutes) {
    QSettings settings;
    settings.setValue("autoLockMinutes", minutes);
    lastActivityTime = QDateTime::currentDateTime();
}

QVariantMap VaultManager::getSecurityReport() {
    QVariantMap report;
    QVariantList weakIds;
    QVariantList reusedIds;
    
    QVariantList entries = getAllEntries();
    int total = entries.size();
    report["totalCount"] = total;
    
    if (total == 0) {
        report["healthScore"] = 100;
        report["weakCount"] = 0;
        report["reusedCount"] = 0;
        report["weakIds"] = weakIds;
        report["reusedIds"] = reusedIds;
        return report;
    }
    
    // Şifre tekrarını (reuse) tespit et
    QMap<QString, int> pwdFrequency;
    for (const QVariant& v : entries) {
        QVariantMap entry = v.toMap();
        QString pwd = entry["password"].toString();
        pwdFrequency[pwd] = pwdFrequency.value(pwd, 0) + 1;
    }
    
    int weakCount = 0;
    int reusedCount = 0;
    
    for (const QVariant& v : entries) {
        QVariantMap entry = v.toMap();
        int id = entry["id"].toInt();
        QString pwd = entry["password"].toString();
        
        int strength = checkPasswordStrength(pwd);
        if (strength < 3) {
            weakCount++;
            weakIds.append(id);
        }
        
        if (pwdFrequency.value(pwd, 0) > 1) {
            reusedCount++;
            reusedIds.append(id);
        }
    }
    
    // Sağlık Skoru: 100 üzerinden ağırlıklı ceza puanları
    double weakRatio = (double)weakCount / total;
    double reusedRatio = (double)reusedCount / total;
    
    int score = 100 - (int)(weakRatio * 45.0) - (int)(reusedRatio * 45.0);
    if (score < 10) score = 10;
    if (score > 100) score = 100;
    
    report["healthScore"] = score;
    report["weakCount"] = weakCount;
    report["reusedCount"] = reusedCount;
    report["weakIds"] = weakIds;
    report["reusedIds"] = reusedIds;
    return report;
}
