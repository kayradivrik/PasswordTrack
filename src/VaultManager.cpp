#include "VaultManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QVariant>
#include <QGuiApplication>
#include <QClipboard>
#include <QCryptographicHash>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QRegularExpression>
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/hmac.h>
#include <openssl/crypto.h>
#include <QWindow>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QStandardPaths>
#include <QSettings>
#include <QUrl>
#include <QTextStream>
#include <QStringConverter>
#include <QEvent>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QtConcurrent/QtConcurrent>
#include <QFuture>
#include <QFutureWatcher>
#include <QTcpServer>
#include <QTcpSocket>
#include <QUrlQuery>
#include <QCoreApplication>
#include <QSharedPointer>
#include <QHostAddress>
#include <functional>
#include <ctime>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

namespace {
const int KEY_LEN = 32;
const int SALT_LEN = 16;
const int IV_LEN = 12;
const int TAG_LEN = 16;
const int MODERN_PBKDF2_ITER = 600000;
const int LEGACY_PBKDF2_ITER = 100000;
const QString CANARY_TEXT = "SYSTEM_CANARY_VALID";

// Base32 Decoder for RFC 6238 TOTP
QByteArray decodeBase32(const QString& input) {
    QString clean = input.toUpper().remove(' ').remove('-').remove('=');
    const QString alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    
    QByteArray result;
    int buffer = 0;
    int bitsLeft = 0;

    for (QChar c : clean) {
        int val = alphabet.indexOf(c);
        if (val < 0) continue;
        buffer = (buffer << 5) | val;
        bitsLeft += 5;
        if (bitsLeft >= 8) {
            bitsLeft -= 8;
            result.append(static_cast<char>((buffer >> bitsLeft) & 0xFF));
        }
    }
    return result;
}

// Simple CSV parser for quoted fields
QStringList parseCsvLine(const QString& line) {
    QStringList fields;
    QString current;
    bool inQuotes = false;
    for (int i = 0; i < line.length(); ++i) {
        QChar c = line[i];
        if (c == '"') {
            if (inQuotes && i + 1 < line.length() && line[i + 1] == '"') {
                current += '"';
                ++i;
            } else {
                inQuotes = !inQuotes;
            }
        } else if (c == ',' && !inQuotes) {
            fields.append(current.trimmed());
            current.clear();
        } else {
            current += c;
        }
    }
    fields.append(current.trimmed());
    return fields;
}
}

VaultManager::VaultManager(QObject* parent) : QObject(parent) {
    netManager = new QNetworkAccessManager(this);
    initDatabase();

    // Pano güvenliği (30 saniye sonra clipboard temizliği)
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

    // Otomatik kilit mekanizması
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

    // TOTP periyodik tick timer (1 saniyede bir kalan süreyi yay)
    totpTimer = new QTimer(this);
    connect(totpTimer, &QTimer::timeout, this, [this]() {
        emit totpTick(getTotpRemainingSeconds());
    });
    totpTimer->start(1000);

    // Tarayıcı eklentisi yerel köprüsü (Autofill API)
    QSettings settings;
    if (settings.value("browserHostEnabled", true).toBool()) {
        startBrowserHostServer();
    }
}

VaultManager::~VaultManager() {
    stopBrowserHostServer();
    encryptionKey.clear();
    if (db.isOpen()) db.close();
}

void VaultManager::secureZeroMemory(QByteArray& data) {
    if (!data.isEmpty()) {
        OPENSSL_cleanse(data.data(), data.size());
        data.clear();
    }
}

QString VaultManager::getDatabaseFilePath() {
    QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(appDataDir);
    QString targetDb = QDir(appDataDir).filePath("vault.db");

    // Geriye dönük uyumluluk: Eğer çalışma dizininde eski vault.db varsa AppData'ya taşı
    QFile localDb("vault.db");
    if (localDb.exists() && !QFile::exists(targetDb)) {
        QFile::copy("vault.db", targetDb);
    }

    return targetDb;
}

bool VaultManager::initDatabase() {
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(getDatabaseFilePath());
    if (!db.open()) return false;

    QSqlQuery query;
    query.exec("CREATE TABLE IF NOT EXISTS metadata (key TEXT PRIMARY KEY, value TEXT)");
    query.exec("CREATE TABLE IF NOT EXISTS vault (id INTEGER PRIMARY KEY AUTOINCREMENT, payload BLOB)");
    query.exec("CREATE TABLE IF NOT EXISTS leak_cache (id INTEGER PRIMARY KEY, pwned INTEGER, checked_at TEXT)");
    return true;
}

void VaultManager::migrateDatabaseIfNeeded() {
    if (encryptionKey.isEmpty()) return;

    QSqlRecord record = db.record("vault");
    // Eski şemada service ve username sütunları varsa
    if (record.contains("service") && record.contains("username")) {
        struct OldRow {
            int id;
            QString service;
            QString username;
            QByteArray payload;
        };
        QList<OldRow> oldRows;
        QSqlQuery fetch("SELECT id, service, username, payload FROM vault");
        while (fetch.next()) {
            oldRows.append({
                fetch.value(0).toInt(),
                fetch.value(1).toString(),
                fetch.value(2).toString(),
                fetch.value(3).toByteArray()
            });
        }

        // Tabloyu yeni sıfır-bilgili (zero-knowledge) şemaya geçir
        db.transaction();
        QSqlQuery drop("DROP TABLE vault");
        drop.exec();
        QSqlQuery createNew("CREATE TABLE vault (id INTEGER PRIMARY KEY AUTOINCREMENT, payload BLOB)");
        createNew.exec();

        for (const auto& row : oldRows) {
            QString plainPwd = QString::fromUtf8(decryptData(row.payload, encryptionKey.toByteArray()));
            QJsonObject obj;
            obj["service"] = row.service;
            obj["username"] = row.username;
            obj["password"] = plainPwd;
            obj["url"] = "";
            obj["notes"] = "";
            obj["totpSecret"] = "";
            obj["category"] = "general";
            obj["isFavorite"] = false;
            obj["history"] = QJsonArray();
            obj["createdAt"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
            obj["updatedAt"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);

            QByteArray jsonBytes = QJsonDocument(obj).toJson(QJsonDocument::Compact);
            QByteArray encrypted = encryptData(jsonBytes, encryptionKey.toByteArray());

            QSqlQuery ins;
            ins.prepare("INSERT INTO vault (id, payload) VALUES (:id, :p)");
            ins.bindValue(":id", row.id);
            ins.bindValue(":p", encrypted);
            ins.exec();
        }
        db.commit();
    }
}

QByteArray VaultManager::deriveKey(const QString& password, const QByteArray& salt, int iterations) {
    QByteArray key(KEY_LEN, 0);
    QByteArray pwd = password.toUtf8();
    PKCS5_PBKDF2_HMAC(pwd.constData(), pwd.length(),
                      reinterpret_cast<const unsigned char*>(salt.constData()), salt.length(),
                      iterations, EVP_sha256(), KEY_LEN,
                      reinterpret_cast<unsigned char*>(key.data()));
    return key;
}

QByteArray VaultManager::encryptData(const QByteArray& plaintext, const QByteArray& key) {
    QByteArray iv(IV_LEN, 0);
    RAND_bytes(reinterpret_cast<unsigned char*>(iv.data()), IV_LEN);
    
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    int len = 0, ciphertext_len = 0;
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
    int len = 0, plaintext_len = 0, ret = 0;

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
    
    QByteArray key = deriveKey(masterPassword, salt, MODERN_PBKDF2_ITER);
    QByteArray encryptedCanary = encryptData(CANARY_TEXT.toUtf8(), key);

    QSqlQuery query;
    query.prepare("INSERT OR REPLACE INTO metadata (key, value) VALUES ('salt', :salt), ('canary', :canary), ('kdf_iter', :iter)");
    query.bindValue(":salt", salt.toBase64());
    query.bindValue(":canary", encryptedCanary.toBase64());
    query.bindValue(":iter", QString::number(MODERN_PBKDF2_ITER));
    
    if (query.exec()) {
        encryptionKey.set(key); secureZeroMemory(key);
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

    int iterations = LEGACY_PBKDF2_ITER;
    query.exec("SELECT value FROM metadata WHERE key='kdf_iter'");
    if (query.next()) {
        iterations = query.value(0).toInt();
    }

    QByteArray key = deriveKey(masterPassword, salt, iterations);
    QByteArray decryptedCanary = decryptData(encryptedCanary, key);

    if (decryptedCanary == CANARY_TEXT.toUtf8()) {
        QSettings settings; settings.setValue("failedUnlockAttempts", 0);
        encryptionKey.set(key); secureZeroMemory(key);
        lastActivityTime = QDateTime::currentDateTime();

        if (iterations < MODERN_PBKDF2_ITER) {
            changeMasterPassword(masterPassword, masterPassword);
        }

        migrateDatabaseIfNeeded();
        return true;
    } else {
        secureZeroMemory(key);
        QSettings settings;
        int current = settings.value("failedUnlockAttempts", 0).toInt() + 1;
        settings.setValue("failedUnlockAttempts", current);
        
        int limit = getSelfDestructAttempts();
        if (limit > 0 && current >= limit) {
            wipeVault();
            settings.setValue("failedUnlockAttempts", 0);
        }
        return false;
    }
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

    QSqlRecord record = db.record("vault");
    bool isLegacy = record.contains("service") && record.contains("username");

    if (isLegacy) {
        QSqlQuery query("SELECT id, service, username, payload FROM vault");
        while (query.next()) {
            QVariantMap entry;
            entry["id"] = query.value(0).toInt();
            entry["service"] = query.value(1).toString();
            entry["username"] = query.value(2).toString();
            QByteArray payload = query.value(3).toByteArray();
            entry["password"] = QString::fromUtf8(decryptData(payload, encryptionKey.toByteArray()));
            entry["url"] = "";
            entry["notes"] = "";
            entry["totpSecret"] = "";
            entry["category"] = "general";
            entry["isFavorite"] = false;
            entry["history"] = QVariantList();
            entries.append(entry);
        }
        return entries;
    }

    QSqlQuery query("SELECT id, payload FROM vault");
    while (query.next()) {
        int id = query.value(0).toInt();
        QByteArray payload = query.value(1).toByteArray();
        QByteArray decrypted = decryptData(payload, encryptionKey.toByteArray());
        
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(decrypted, &parseError);
        if (parseError.error == QJsonParseError::NoError && doc.isObject()) {
            QVariantMap entry = doc.object().toVariantMap();
            entry["id"] = id;
            if (!entry.contains("category")) entry["category"] = "general";
            if (!entry.contains("isFavorite")) entry["isFavorite"] = false;
            entries.append(entry);
        }
    }
    return entries;
}

QVariantMap VaultManager::getEntryById(int id) {
    QVariantMap res;
    if (encryptionKey.isEmpty()) return res;

    QSqlQuery query;
    query.prepare("SELECT payload FROM vault WHERE id = :id");
    query.bindValue(":id", id);
    if (query.exec() && query.next()) {
        QByteArray payload = query.value(0).toByteArray();
        QByteArray decrypted = decryptData(payload, encryptionKey.toByteArray());
        QJsonDocument doc = QJsonDocument::fromJson(decrypted);
        if (doc.isObject()) {
            res = doc.object().toVariantMap();
            res["id"] = id;
        }
    }
    return res;
}

bool VaultManager::addEntry(const QString& service, const QString& username, const QString& password,
                            const QString& url, const QString& notes, const QString& totpSecret,
                            const QString& category, bool isFavorite) {
    if (encryptionKey.isEmpty()) return false;

    QJsonObject obj;
    obj["service"] = service.trimmed();
    obj["username"] = username.trimmed();
    obj["password"] = password;
    obj["url"] = url.trimmed();
    obj["notes"] = notes;
    obj["totpSecret"] = totpSecret.trimmed();
    obj["category"] = category.isEmpty() ? "general" : category;
    obj["isFavorite"] = isFavorite;
    obj["history"] = QJsonArray();
    obj["createdAt"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
    obj["updatedAt"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);

    QByteArray jsonBytes = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    QByteArray payload = encryptData(jsonBytes, encryptionKey.toByteArray());

    QSqlQuery query;
    query.prepare("INSERT INTO vault (payload) VALUES (:p)");
    query.bindValue(":p", payload);
    bool ok = query.exec();
    // Yeni parola kaydedildiğinde sızıntı kontrolü yalnızca bir kez yapılır
    if (ok) checkPwnedAsync(query.lastInsertId().toInt(), password);
    return ok;
}

bool VaultManager::updateEntry(int id, const QString& service, const QString& username, const QString& password,
                               const QString& url, const QString& notes, const QString& totpSecret,
                               const QString& category, bool isFavorite) {
    if (encryptionKey.isEmpty()) return false;

    QVariantMap existing = getEntryById(id);
    QJsonArray historyArr = QJsonValue::fromVariant(existing.value("history")).toArray();

    // Parola değişmişse eski parolayı geçmişe (history) ekle
    QString oldPassword = existing.value("password").toString();
    if (!oldPassword.isEmpty() && oldPassword != password) {
        QJsonObject histItem;
        histItem["password"] = oldPassword;
        histItem["changedAt"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
        historyArr.prepend(histItem);
        // Maksimum 10 eski parola tut
        while (historyArr.size() > 10) {
            historyArr.removeLast();
        }
    }

    QJsonObject obj;
    obj["service"] = service.trimmed();
    obj["username"] = username.trimmed();
    obj["password"] = password;
    obj["url"] = url.trimmed();
    obj["notes"] = notes;
    obj["totpSecret"] = totpSecret.trimmed();
    obj["category"] = category.isEmpty() ? "general" : category;
    obj["isFavorite"] = isFavorite;
    obj["history"] = historyArr;
    obj["createdAt"] = existing.contains("createdAt") ? existing.value("createdAt").toString() : QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
    obj["updatedAt"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);

    QByteArray jsonBytes = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    QByteArray payload = encryptData(jsonBytes, encryptionKey.toByteArray());

    QSqlQuery query;
    query.prepare("UPDATE vault SET payload = :p WHERE id = :id");
    query.bindValue(":p", payload);
    query.bindValue(":id", id);
    bool ok = query.exec();
    // Parola değiştiyse sızıntı kontrolünü yalnızca bir kez yeniden çalıştır
    if (ok && oldPassword != password) {
        QSqlQuery del;
        del.prepare("DELETE FROM leak_cache WHERE id = :id");
        del.bindValue(":id", id);
        del.exec();
        checkPwnedAsync(id, password);
    }
    return ok;
}

bool VaultManager::toggleFavorite(int id) {
    QVariantMap entry = getEntryById(id);
    if (entry.isEmpty()) return false;
    bool newFav = !entry.value("isFavorite", false).toBool();
    return updateEntry(id,
                       entry.value("service").toString(),
                       entry.value("username").toString(),
                       entry.value("password").toString(),
                       entry.value("url").toString(),
                       entry.value("notes").toString(),
                       entry.value("totpSecret").toString(),
                       entry.value("category").toString(),
                       newFav);
}

bool VaultManager::deleteEntry(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM vault WHERE id = :id");
    query.bindValue(":id", id);
    return query.exec();
}

QVariantList VaultManager::getPasswordHistory(int id) {
    QVariantMap entry = getEntryById(id);
    return entry.value("history").toList();
}

void VaultManager::copyToClipboard(const QString& text) {
    if (QClipboard *clipboard = QGuiApplication::clipboard()) {
        lastCopiedPassword = text;
        clipboard->setText(text);
        clipboardClearTimer->start(30000);
        emit clipboardCopied(30);
    }
}

// RFC 6238 TOTP Kod Üretimi
QString VaultManager::generateTotp(const QString& secret) {
    if (secret.trimmed().isEmpty()) return "";

    QByteArray key = decodeBase32(secret);
    if (key.isEmpty()) return "";

    uint64_t step = 30;
    uint64_t counter = static_cast<uint64_t>(std::time(nullptr)) / step;

    // Big-endian 8 byte array
    unsigned char msg[8];
    for (int i = 7; i >= 0; --i) {
        msg[i] = counter & 0xFF;
        counter >>= 8;
    }

    unsigned char hmacRes[EVP_MAX_MD_SIZE];
    unsigned int hmacLen = 0;

    HMAC(EVP_sha1(),
         key.constData(), key.length(),
         msg, sizeof(msg),
         hmacRes, &hmacLen);

    if (hmacLen < 20) return "";

    int offset = hmacRes[19] & 0x0F;
    uint32_t binary =
        ((hmacRes[offset] & 0x7F) << 24) |
        ((hmacRes[offset + 1] & 0xFF) << 16) |
        ((hmacRes[offset + 2] & 0xFF) << 8) |
        (hmacRes[offset + 3] & 0xFF);

    uint32_t otp = binary % 1000000;
    return QString("%1").arg(otp, 6, 10, QChar('0'));
}

int VaultManager::getTotpRemainingSeconds() {
    int now = static_cast<int>(std::time(nullptr));
    return 30 - (now % 30);
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
    request.setHeader(QNetworkRequest::UserAgentHeader, "VoidPass-Security-Client");
    
    QNetworkReply* reply = netManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, id, suffix]() {
        if(reply->error() == QNetworkReply::NoError) {
            QString response = reply->readAll();
            bool pwned = response.contains(suffix);
            QSqlQuery store;
            store.prepare("INSERT OR REPLACE INTO leak_cache (id, pwned, checked_at) VALUES (:id, :p, :t)");
            store.bindValue(":id", id);
            store.bindValue(":p", pwned ? 1 : 0);
            store.bindValue(":t", QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
            store.exec();
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
#else
    Q_UNUSED(enabled);
#endif
}

void VaultManager::wipeVault() {
    encryptionKey.clear();
    db.close();
    QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);
    QFile::remove(getDatabaseFilePath());
    initDatabase();
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

bool VaultManager::changeMasterPassword(const QString& currentPassword, const QString& newPassword) {
    if (newPassword.trimmed().isEmpty()) return false;

    // 1. Mevcut ana parolayı doğrula
    QSqlQuery query("SELECT value FROM metadata WHERE key='salt'");
    if (!query.next()) return false;
    QByteArray currentSalt = QByteArray::fromBase64(query.value(0).toByteArray());

    query.exec("SELECT value FROM metadata WHERE key='canary'");
    if (!query.next()) return false;
    QByteArray currentEncryptedCanary = QByteArray::fromBase64(query.value(0).toByteArray());

    int currentIter = LEGACY_PBKDF2_ITER;
    query.exec("SELECT value FROM metadata WHERE key='kdf_iter'");
    if (query.next()) currentIter = query.value(0).toInt();

    QByteArray testKey = deriveKey(currentPassword, currentSalt, currentIter);
    QByteArray decryptedCanary = decryptData(currentEncryptedCanary, testKey);

    if (decryptedCanary != CANARY_TEXT.toUtf8()) {
        secureZeroMemory(testKey);
        return false;
    }

    // 2. Mevcut tüm kayıtları çözüp RAM'e al
    struct DecryptedItem {
        int id;
        QByteArray plaintext;
    };
    QList<DecryptedItem> decryptedList;

    QSqlQuery fetchQuery("SELECT id, payload FROM vault");
    while (fetchQuery.next()) {
        DecryptedItem item;
        item.id = fetchQuery.value(0).toInt();
        QByteArray payload = fetchQuery.value(1).toByteArray();
        item.plaintext = decryptData(payload, testKey);
        decryptedList.append(item);
    }

    secureZeroMemory(testKey);

    // 3. Yeni parola için 600.000 iterasyonlu yeni Salt ve Anahtar türet
    QByteArray newSalt(SALT_LEN, 0);
    RAND_bytes(reinterpret_cast<unsigned char*>(newSalt.data()), SALT_LEN);
    QByteArray newKey = deriveKey(newPassword, newSalt, MODERN_PBKDF2_ITER);
    QByteArray newEncryptedCanary = encryptData(CANARY_TEXT.toUtf8(), newKey);

    if (!db.transaction()) {
        secureZeroMemory(newKey);
        return false;
    }

    QSqlQuery updateMetaQuery;
    updateMetaQuery.prepare("INSERT OR REPLACE INTO metadata (key, value) VALUES ('salt', :salt), ('canary', :canary), ('kdf_iter', :iter)");
    updateMetaQuery.bindValue(":salt", newSalt.toBase64());
    updateMetaQuery.bindValue(":canary", newEncryptedCanary.toBase64());
    updateMetaQuery.bindValue(":iter", QString::number(MODERN_PBKDF2_ITER));
    if (!updateMetaQuery.exec()) {
        db.rollback();
        secureZeroMemory(newKey);
        return false;
    }

    for (const auto& item : decryptedList) {
        QByteArray newPayload = encryptData(item.plaintext, newKey);
        QSqlQuery updateVaultQuery;
        updateVaultQuery.prepare("UPDATE vault SET payload = :p WHERE id = :id");
        updateVaultQuery.bindValue(":p", newPayload);
        updateVaultQuery.bindValue(":id", item.id);
        if (!updateVaultQuery.exec()) {
            db.rollback();
            secureZeroMemory(newKey);
            return false;
        }
    }

    if (!db.commit()) {
        db.rollback();
        secureZeroMemory(newKey);
        return false;
    }

    encryptionKey.clear();
    encryptionKey.set(newKey); secureZeroMemory(newKey);
    lastActivityTime = QDateTime::currentDateTime();
    return true;
}

bool VaultManager::exportToCSV(const QString& filePath) {
    if (encryptionKey.isEmpty()) return false;

    QString localPath = filePath;
    if (localPath.startsWith("file:///")) localPath = QUrl(localPath).toLocalFile();
    else if (localPath.startsWith("file://")) localPath = QUrl(localPath).toLocalFile();

    QFile file(localPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) return false;

    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);
    out.setGenerateByteOrderMark(true);
    out << "\"Servis\",\"Kullanıcı Adı\",\"Parola\",\"URL\",\"Notlar\",\"TOTP\",\"Kategori\"\n";

    auto escapeCsv = [](QString field) -> QString {
        field.replace("\"", "\"\"");
        return "\"" + field + "\"";
    };

    QVariantList entries = getAllEntries();
    for (const QVariant& v : entries) {
        QVariantMap entry = v.toMap();
        out << escapeCsv(entry["service"].toString()) << ","
            << escapeCsv(entry["username"].toString()) << ","
            << escapeCsv(entry["password"].toString()) << ","
            << escapeCsv(entry["url"].toString()) << ","
            << escapeCsv(entry["notes"].toString()) << ","
            << escapeCsv(entry["totpSecret"].toString()) << ","
            << escapeCsv(entry["category"].toString()) << "\n";
    }

    file.close();
    return true;
}

QVariantMap VaultManager::importFromCSV(const QString& filePath) {
    QVariantMap res;
    res["success"] = false;
    res["importedCount"] = 0;
    res["failedCount"] = 0;

    if (encryptionKey.isEmpty()) return res;

    QString localPath = filePath;
    if (localPath.startsWith("file:///")) localPath = QUrl(localPath).toLocalFile();
    else if (localPath.startsWith("file://")) localPath = QUrl(localPath).toLocalFile();

    QFile file(localPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return res;

    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);

    if (in.atEnd()) return res;

    QString headerLine = in.readLine().toLower();
    QStringList headers = parseCsvLine(headerLine);

    // Sütun indexlerini tespit et
    int idxService = -1;
    int idxUsername = -1;
    int idxPassword = -1;
    int idxUrl = -1;
    int idxNotes = -1;
    int idxTotp = -1;

    for (int i = 0; i < headers.size(); ++i) {
        QString h = headers[i].trimmed();
        if (h == "servis" || h == "service" || h == "name" || h == "title") idxService = i;
        else if (h == "kullanıcı adı" || h == "username" || h == "login_username" || h == "email") idxUsername = i;
        else if (h == "parola" || h == "password" || h == "login_password") idxPassword = i;
        else if (h == "url" || h == "login_uri" || h == "website") idxUrl = i;
        else if (h == "notlar" || h == "notes" || h == "note") idxNotes = i;
        else if (h == "totp" || h == "login_totp" || h == "totpsecret") idxTotp = i;
    }

    // En azından servis/isim ve parola veya kullanıcı adı tespit edilmiş olmalı
    if (idxService == -1 && idxUrl != -1) idxService = idxUrl;
    if (idxPassword == -1) return res;

    int imported = 0;
    int failed = 0;

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList fields = parseCsvLine(line);
        if (fields.size() <= idxPassword) {
            failed++;
            continue;
        }

        QString service = (idxService >= 0 && idxService < fields.size()) ? fields[idxService] : "İçe Aktarılan";
        QString username = (idxUsername >= 0 && idxUsername < fields.size()) ? fields[idxUsername] : "";
        QString password = fields[idxPassword];
        QString url = (idxUrl >= 0 && idxUrl < fields.size()) ? fields[idxUrl] : "";
        QString notes = (idxNotes >= 0 && idxNotes < fields.size()) ? fields[idxNotes] : "";
        QString totp = (idxTotp >= 0 && idxTotp < fields.size()) ? fields[idxTotp] : "";

        if (service.isEmpty() && !url.isEmpty()) service = url;
        if (service.isEmpty()) service = "Hesap";

        if (!password.isEmpty()) {
            if (addEntry(service, username, password, url, notes, totp, "general", false)) {
                imported++;
            } else {
                failed++;
            }
        }
    }

    file.close();
    res["success"] = true;
    res["importedCount"] = imported;
    res["failedCount"] = failed;
    return res;
}

bool VaultManager::exportVaultBackup(const QString& filePath) {
    if (encryptionKey.isEmpty()) return false;

    QString localPath = filePath;
    if (localPath.startsWith("file:///")) localPath = QUrl(localPath).toLocalFile();
    else if (localPath.startsWith("file://")) localPath = QUrl(localPath).toLocalFile();

    QSqlQuery metaQuery("SELECT key, value FROM metadata");
    QString salt, canary, iter;
    while (metaQuery.next()) {
        QString k = metaQuery.value(0).toString();
        if (k == "salt") salt = metaQuery.value(1).toString();
        else if (k == "canary") canary = metaQuery.value(1).toString();
        else if (k == "kdf_iter") iter = metaQuery.value(1).toString();
    }

    if (salt.isEmpty() || canary.isEmpty()) return false;

    QJsonArray entriesArray;
    QSqlQuery vaultQuery("SELECT id, payload FROM vault ORDER BY id ASC");
    QCryptographicHash hash(QCryptographicHash::Sha256);
    hash.addData(salt.toUtf8());
    hash.addData(canary.toUtf8());

    while (vaultQuery.next()) {
        QJsonObject obj;
        int id = vaultQuery.value(0).toInt();
        QByteArray payload = vaultQuery.value(1).toByteArray();

        obj["id"] = id;
        obj["payload"] = QString::fromLatin1(payload.toBase64());
        hash.addData(payload);
        entriesArray.append(obj);
    }

    QJsonObject root;
    root["format"] = "VoidPass.VaultBackup";
    root["version"] = 2;
    root["created_at"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
    root["salt"] = salt;
    root["canary"] = canary;
    root["kdf_iter"] = iter.isEmpty() ? QString::number(MODERN_PBKDF2_ITER) : iter;
    root["entries"] = entriesArray;
    root["checksum"] = QString::fromLatin1(hash.result().toHex());

    QFile file(localPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) return false;

    QJsonDocument doc(root);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return true;
}

QVariantMap VaultManager::inspectVaultBackup(const QString& filePath) {
    QVariantMap res;
    res["valid"] = false;
    res["entryCount"] = 0;
    res["createdAt"] = "";
    res["canMerge"] = false;

    QString localPath = filePath;
    if (localPath.startsWith("file:///")) localPath = QUrl(localPath).toLocalFile();
    else if (localPath.startsWith("file://")) localPath = QUrl(localPath).toLocalFile();

    QFile file(localPath);
    if (!file.open(QIODevice::ReadOnly)) return res;

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
    file.close();
    if (parseError.error != QJsonParseError::NoError || !doc.isObject()) return res;

    QJsonObject root = doc.object();
    QString fmt = root["format"].toString();
    if (fmt != "VoidPass.VaultBackup" && fmt != "PasswordTrack.VaultBackup") return res;
    if (!root.contains("salt") || !root.contains("canary") || !root.contains("entries")) return res;

    QString salt = root["salt"].toString();
    QString canary = root["canary"].toString();
    QJsonArray entries = root["entries"].toArray();

    QSqlQuery query("SELECT value FROM metadata WHERE key='salt'");
    QString currentSalt;
    if (query.next()) currentSalt = query.value(0).toString();
    query.exec("SELECT value FROM metadata WHERE key='canary'");
    QString currentCanary;
    if (query.next()) currentCanary = query.value(0).toString();

    bool sameMasterKey = (!currentSalt.isEmpty() && currentSalt == salt && currentCanary == canary);

    res["valid"] = true;
    res["entryCount"] = entries.size();
    res["createdAt"] = root["created_at"].toString();
    res["canMerge"] = sameMasterKey && isUnlocked();
    res["filePath"] = localPath;
    return res;
}

bool VaultManager::restoreVaultBackup(const QString& filePath, bool merge) {
    QVariantMap info = inspectVaultBackup(filePath);
    if (!info["valid"].toBool()) return false;

    QString localPath = filePath;
    if (localPath.startsWith("file:///")) localPath = QUrl(localPath).toLocalFile();
    else if (localPath.startsWith("file://")) localPath = QUrl(localPath).toLocalFile();

    QFile file(localPath);
    if (!file.open(QIODevice::ReadOnly)) return false;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    QJsonObject root = doc.object();
    QString salt = root["salt"].toString();
    QString canary = root["canary"].toString();
    QString iter = root.value("kdf_iter").toString();
    if (iter.isEmpty()) iter = QString::number(MODERN_PBKDF2_ITER);
    QJsonArray entries = root["entries"].toArray();

    if (!db.transaction()) return false;

    if (!merge) {
        QSqlQuery delMeta("DELETE FROM metadata");
        delMeta.exec();
        QSqlQuery insertMeta;
        insertMeta.prepare("INSERT INTO metadata (key, value) VALUES ('salt', :s), ('canary', :c), ('kdf_iter', :iter)");
        insertMeta.bindValue(":s", salt);
        insertMeta.bindValue(":c", canary);
        insertMeta.bindValue(":iter", iter);
        if (!insertMeta.exec()) {
            db.rollback();
            return false;
        }

        QSqlQuery delVault("DELETE FROM vault");
        delVault.exec();

        for (const auto& item : entries) {
            QJsonObject obj = item.toObject();
            QSqlQuery insertVault;
            insertVault.prepare("INSERT INTO vault (payload) VALUES (:p)");
            insertVault.bindValue(":p", QByteArray::fromBase64(obj["payload"].toString().toLatin1()));
            if (!insertVault.exec()) {
                db.rollback();
                return false;
            }
        }

        if (!db.commit()) {
            db.rollback();
            return false;
        }

        lockVault();
        return true;
    } else {
        for (const auto& item : entries) {
            QJsonObject obj = item.toObject();
            QSqlQuery insertVault;
            insertVault.prepare("INSERT INTO vault (payload) VALUES (:p)");
            insertVault.bindValue(":p", QByteArray::fromBase64(obj["payload"].toString().toLatin1()));
            insertVault.exec();
        }
        if (!db.commit()) {
            db.rollback();
            return false;
        }
        return true;
    }
}

bool VaultManager::generateEmergencyKit(const QString& filePath) {
    QString localPath = filePath;
    if (localPath.startsWith("file:///")) localPath = QUrl(localPath).toLocalFile();
    else if (localPath.startsWith("file://")) localPath = QUrl(localPath).toLocalFile();

    if (!localPath.endsWith(".html", Qt::CaseInsensitive)) {
        localPath += ".html";
    }

    QFile file(localPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) return false;

    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);

    QString dateStr = QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm");

    out << "<!DOCTYPE html>\n"
        << "<html lang=\"tr\">\n"
        << "<head>\n"
        << "<meta charset=\"UTF-8\">\n"
        << "<title>VoidPass - Acil Durum Kurtarma Kiti</title>\n"
        << "<style>\n"
        << "body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background: #f8fafc; color: #1e293b; padding: 40px; margin: 0; line-height: 1.5; }\n"
        << ".container { max-width: 760px; margin: 0 auto; background: #ffffff; border: 2px solid #e2e8f0; border-radius: 12px; padding: 40px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }\n"
        << ".header { display: flex; align-items: center; justify-content: space-between; border-bottom: 2px solid #e2e8f0; padding-bottom: 20px; margin-bottom: 24px; }\n"
        << ".title { font-size: 26px; font-weight: 800; color: #0f172a; margin: 0; }\n"
        << ".badge { background: #0ea5e9; color: white; padding: 6px 12px; border-radius: 6px; font-size: 13px; font-weight: bold; }\n"
        << ".warning { background: #fff1f2; border: 1px solid #fecdd3; border-radius: 8px; padding: 16px; margin: 20px 0; color: #9f1239; font-size: 14px; }\n"
        << ".field-box { border: 2px dashed #cbd5e1; border-radius: 8px; padding: 18px; margin: 16px 0; background: #f8fafc; }\n"
        << ".field-label { font-size: 12px; text-transform: uppercase; font-weight: 700; color: #64748b; margin-bottom: 6px; }\n"
        << ".field-value { font-family: monospace; font-size: 18px; font-weight: 700; color: #0f172a; min-height: 28px; }\n"
        << ".steps { margin: 24px 0; }\n"
        << ".steps li { margin-bottom: 10px; font-size: 14px; color: #334155; }\n"
        << ".footer { margin-top: 36px; border-top: 1px solid #e2e8f0; padding-top: 16px; font-size: 12px; color: #94a3b8; text-align: center; }\n"
        << "@media print { body { padding: 0; background: white; } .container { border: none; box-shadow: none; padding: 20px; } }\n"
        << "</style>\n"
        << "</head>\n"
        << "<body>\n"
        << "<div class=\"container\">\n"
        << "<div class=\"header\">\n"
        << "<div>\n"
        << "<h1 class=\"title\">VOIDPASS</h1>\n"
        << "<div style=\"color:#64748b; font-size:14px; margin-top:4px;\">Acil Durum Kurtarma Kiti (Emergency Kit)</div>\n"
        << "</div>\n"
        << "<div class=\"badge\">GÜVENLİ VE ÇEVRİMDIŞI</div>\n"
        << "</div>\n"
        << "<div class=\"warning\">\n"
        << "<strong>DİKKAT:</strong> Bu belge, kasanıza ve tüm parolalarınıza erişim anahtarlarını barındırır. Bu belgeyi yazdırıp fiziksel olarak güvenli bir yerde (örneğin kilitli çekmece veya kasa) saklayın. Dijital ortamda şifresiz paylaşmayın!\n"
        << "</div>\n"
        << "<div class=\"field-box\">\n"
        << "<div class=\"field-label\">Oluşturulma Tarihi</div>\n"
        << "<div class=\"field-value\">" << dateStr << "</div>\n"
        << "</div>\n"
        << "<div class=\"field-box\">\n"
        << "<div class=\"field-label\">Ana Parolanız (Master Password)</div>\n"
        << "<div class=\"field-value\" style=\"color: #0369a1;\">____________________________________________________</div>\n"
        << "<div style=\"font-size:12px; color:#64748b; margin-top:6px;\">* Ana parolanızı yukarıdaki alana el yazınızla kaydedebilirsiniz.</div>\n"
        << "</div>\n"
        << "<div class=\"field-box\">\n"
        << "<div class=\"field-label\">Kasa Veritabanı Yolu</div>\n"
        << "<div class=\"field-value\" style=\"font-size:13px;\">" << getDatabaseFilePath() << "</div>\n"
        << "</div>\n"
        << "<h3>Kurtarma Adımları</h3>\n"
        << "<ol class=\"steps\">\n"
        << "<li>Cihazınızda <strong>VoidPass</strong> uygulamasını açın.</li>\n"
        << "<li>Kasa kilit ekranında bu belgede yer alan <strong>Ana Parola</strong>nızı girin.</li>\n"
        << "<li>Yeni bir cihaza geçiyorsanız, önceki cihazınızdaki <code>vault.db</code> dosyasını veya <code>.vault</code> yedeğinizi içe aktarın.</li>\n"
        << "<li>Ana parolanızı unuttuysanız ve yedek anahtarınız yoksa, AES-256-GCM şifreleme nedeniyle kasanız geri alınamaz.</li>\n"
        << "</ol>\n"
        << "<div class=\"footer\">VoidPass Offline Password Manager &bull; Güvenlik &bull; Gizlilik &bull; Kontrol Sizde</div>\n"
        << "</div>\n"
        << "</body>\n"
        << "</html>\n";

    file.close();
    return true;
}

// Tercihler ve Ayarlar
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

qreal VaultManager::getUiScale() {
    QSettings settings;
    return settings.value("uiScale", 1.0).toReal();
}

void VaultManager::setUiScale(qreal scale) {
    QSettings settings;
    settings.setValue("uiScale", scale);
}

QString VaultManager::getLanguage() {
    QSettings settings;
    return settings.value("appLanguage", "tr").toString();
}

void VaultManager::setLanguage(const QString& lang) {
    QSettings settings;
    settings.setValue("appLanguage", lang);
}

bool VaultManager::hasSelectedLanguage() {
    QSettings settings;
    return settings.contains("appLanguage");
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

// ============================================================================
// Asenkron Kilit Açma (KDF arka plan iş parçacığında çalışır, arayüz donmaz)
// ============================================================================
void VaultManager::unlockVaultAsync(const QString& masterPassword) {
    QSqlQuery query("SELECT value FROM metadata WHERE key='salt'");
    if (!query.next()) { emit unlockCompleted(false, "no_vault"); return; }
    QByteArray salt = QByteArray::fromBase64(query.value(0).toByteArray());

    query.exec("SELECT value FROM metadata WHERE key='canary'");
    if (!query.next()) { emit unlockCompleted(false, "no_vault"); return; }
    QByteArray encryptedCanary = QByteArray::fromBase64(query.value(0).toByteArray());

    int iterations = LEGACY_PBKDF2_ITER;
    query.exec("SELECT value FROM metadata WHERE key='kdf_iter'");
    if (query.next()) iterations = query.value(0).toInt();

    auto* watcher = new QFutureWatcher<QByteArray>(this);
    connect(watcher, &QFutureWatcher<QByteArray>::finished, this,
            [this, watcher, encryptedCanary, iterations, masterPassword]() {
        QByteArray key = watcher->result();
        watcher->deleteLater();

        if (decryptData(encryptedCanary, key) == CANARY_TEXT.toUtf8()) {
            QSettings settings; settings.setValue("failedUnlockAttempts", 0);
            encryptionKey.set(key); secureZeroMemory(key);
            lastActivityTime = QDateTime::currentDateTime();
            if (iterations < MODERN_PBKDF2_ITER) {
                changeMasterPassword(masterPassword, masterPassword);
            }
            migrateDatabaseIfNeeded();
            createRollingBackup();
            emit unlockCompleted(true, "");
        } else {
            secureZeroMemory(key);
            QSettings settings;
            int current = settings.value("failedUnlockAttempts", 0).toInt() + 1;
            settings.setValue("failedUnlockAttempts", current);
            
            int limit = getSelfDestructAttempts();
            if (limit > 0 && current >= limit) {
                QMetaObject::invokeMethod(this, "wipeVault", Qt::QueuedConnection);
                settings.setValue("failedUnlockAttempts", 0);
                emit unlockCompleted(false, "wiped");
            } else {
                emit unlockCompleted(false, "wrong_password");
            }
        }
    });
    watcher->setFuture(QtConcurrent::run([this, masterPassword, salt, iterations]() {
        return deriveKey(masterPassword, salt, iterations);
    }));
}

// ============================================================================
// Kasa Sızıntı Taraması (manuel) ve yerel önbellek
// ============================================================================
bool VaultManager::isLeakScanning() const { return leakScanning; }

QVariantList VaultManager::getLeakedIds() {
    QVariantList ids;
    QSqlQuery q("SELECT id FROM leak_cache WHERE pwned = 1");
    while (q.next()) ids.append(q.value(0).toInt());
    return ids;
}

void VaultManager::scanVaultForLeaks() {
    if (leakScanning || encryptionKey.isEmpty()) return;
    leakScanning = true;

    struct Item { int id; QString prefix; QString suffix; };
    auto items = QSharedPointer<QList<Item>>::create();
    for (const QVariant& v : getAllEntries()) {
        QVariantMap e = v.toMap();
        QByteArray hash = QCryptographicHash::hash(e["password"].toString().toUtf8(),
                                                   QCryptographicHash::Sha1).toHex().toUpper();
        items->append({e["id"].toInt(), QString(hash.left(5)), QString(hash.mid(5))});
    }

    int total = items->size();
    if (total == 0) {
        leakScanning = false;
        emit leakScanFinished(0);
        return;
    }

    auto index = QSharedPointer<int>::create(0);
    auto leaked = QSharedPointer<int>::create(0);
    auto step = QSharedPointer<std::function<void()>>::create();
    *step = [this, items, index, leaked, step, total]() {
        if (*index >= total) {
            leakScanning = false;
            emit leakScanFinished(*leaked);
            return;
        }
        Item it = items->at(*index);
        QNetworkRequest request(QUrl("https://api.pwnedpasswords.com/range/" + it.prefix));
        request.setHeader(QNetworkRequest::UserAgentHeader, "VoidPass-Security-Client");
        request.setRawHeader("Add-Padding", "true");
        QNetworkReply* reply = netManager->get(request);
        connect(reply, &QNetworkReply::finished, this, [this, reply, it, index, leaked, step, total]() {
            if (reply->error() == QNetworkReply::NoError) {
                bool pwned = QString(reply->readAll()).contains(it.suffix);
                if (pwned) (*leaked)++;
                QSqlQuery store;
                store.prepare("INSERT OR REPLACE INTO leak_cache (id, pwned, checked_at) VALUES (:id, :p, :t)");
                store.bindValue(":id", it.id);
                store.bindValue(":p", pwned ? 1 : 0);
                store.bindValue(":t", QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
                store.exec();
                emit pwnedStatus(it.id, pwned);
            }
            reply->deleteLater();
            (*index)++;
            emit leakScanProgress(*index, total);
            QTimer::singleShot(120, this, [step]() { (*step)(); }); // API'ye nazik davran
        });
    };
    (*step)();
}

// ============================================================================
// Otomatik Dönen Yerel Yedekler (her kilit açılışında, son 5 adet)
// ============================================================================
void VaultManager::createRollingBackup() {
    QString dbPath = getDatabaseFilePath();
    QDir dir(QFileInfo(dbPath).absolutePath());
    dir.mkpath("backups");
    QDir backups(dir.filePath("backups"));
    QString name = "vault_" + QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss") + ".db";
    QFile::copy(dbPath, backups.filePath(name));

    QFileInfoList list = backups.entryInfoList({"vault_*.db"}, QDir::Files, QDir::Name | QDir::Reversed);
    for (int i = 5; i < list.size(); ++i) QFile::remove(list[i].absoluteFilePath());
}

QVariantList VaultManager::getRollingBackups() {
    QVariantList res;
    QDir backups(QDir(QFileInfo(getDatabaseFilePath()).absolutePath()).filePath("backups"));
    for (const QFileInfo& fi : backups.entryInfoList({"vault_*.db"}, QDir::Files, QDir::Name | QDir::Reversed)) {
        QVariantMap m;
        m["path"] = fi.absoluteFilePath();
        m["name"] = fi.fileName();
        m["date"] = fi.lastModified().toString("dd.MM.yyyy HH:mm:ss");
        res.append(m);
    }
    return res;
}

bool VaultManager::restoreRollingBackup(const QString& backupPath) {
    if (!QFile::exists(backupPath)) return false;
    QString dbPath = getDatabaseFilePath();
    encryptionKey.clear();
    db.close();
    QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);
    QFile::remove(dbPath);
    bool ok = QFile::copy(backupPath, dbPath);
    initDatabase();
    emit vaultLocked();
    return ok;
}

// ============================================================================
// Tarayıcı Eklentisi Köprüsü (yalnızca 127.0.0.1, token + origin korumalı)
// ============================================================================
namespace { const quint16 BROWSER_PORT = 38917; }

QString VaultManager::getBrowserToken() {
    QSettings settings;
    QString token = settings.value("browserToken").toString();
    if (token.isEmpty()) {
        QByteArray rnd(24, 0);
        RAND_bytes(reinterpret_cast<unsigned char*>(rnd.data()), rnd.size());
        token = QString::fromLatin1(rnd.toHex());
        settings.setValue("browserToken", token);
    }
    return token;
}

QString VaultManager::getBrowserExtensionPath() {
    QDir app(QCoreApplication::applicationDirPath());
    for (const QString& rel : {"browser-extension", "../browser-extension"}) {
        if (QDir(app.filePath(rel)).exists()) return QDir::cleanPath(app.filePath(rel));
    }
    return QDir::cleanPath(app.filePath("browser-extension"));
}

bool VaultManager::isBrowserHostRunning() const {
    return browserServer && browserServer->isListening();
}

void VaultManager::toggleBrowserHost(bool enable) {
    QSettings settings;
    settings.setValue("browserHostEnabled", enable);
    if (enable) startBrowserHostServer(); else stopBrowserHostServer();
}

void VaultManager::startBrowserHostServer() {
    if (browserServer) return;
    getBrowserToken();
    browserServer = new QTcpServer(this);
    connect(browserServer, &QTcpServer::newConnection, this, [this]() {
        while (QTcpSocket* client = browserServer->nextPendingConnection()) {
            connect(client, &QTcpSocket::readyRead, this, [this, client]() { handleBrowserClient(client); });
            connect(client, &QTcpSocket::disconnected, client, &QObject::deleteLater);
        }
    });
    if (!browserServer->listen(QHostAddress::LocalHost, BROWSER_PORT)) {
        browserServer->deleteLater();
        browserServer = nullptr;
    }
}

void VaultManager::stopBrowserHostServer() {
    if (!browserServer) return;
    browserServer->close();
    browserServer->deleteLater();
    browserServer = nullptr;
}

void VaultManager::handleBrowserClient(QTcpSocket* client) {
    QByteArray raw = client->readAll();
    QList<QByteArray> lines = raw.split('\n');
    if (lines.isEmpty()) { client->disconnectFromHost(); return; }

    QList<QByteArray> reqLine = lines[0].trimmed().split(' ');
    QString method = reqLine.value(0);
    QUrl url(QString::fromLatin1(reqLine.value(1)));

    QString token, origin, host;
    for (const QByteArray& l : lines.mid(1)) {
        QByteArray line = l.trimmed();
        int c = line.indexOf(':');
        if (c < 0) continue;
        QByteArray k = line.left(c).trimmed().toLower();
        QString v = QString::fromUtf8(line.mid(c + 1).trimmed());
        if (k == "x-voidpass-token") token = v;
        else if (k == "origin") origin = v;
        else if (k == "host") host = v;
    }

    auto respond = [client](int code, const QByteArray& body) {
        QByteArray status = code == 200 ? "OK" : (code == 204 ? "No Content" : "Error");
        QByteArray out = "HTTP/1.1 " + QByteArray::number(code) + " " + status + "\r\n"
                         "Content-Type: application/json\r\n"
                         "Access-Control-Allow-Origin: *\r\n"
                         "Access-Control-Allow-Headers: X-VoidPass-Token\r\n"
                         "Content-Length: " + QByteArray::number(body.size()) + "\r\n"
                         "Connection: close\r\n\r\n" + body;
        client->write(out);
        client->disconnectFromHost();
    };

    // DNS rebinding / web sayfası saldırılarına karşı: sadece eklenti origin'i ve yerel host
    bool hostOk = host.startsWith("127.0.0.1") || host.startsWith("localhost");
    bool originOk = origin.isEmpty() || origin.startsWith("chrome-extension://") || origin.startsWith("moz-extension://");
    if (!hostOk || !originOk) { respond(403, "{\"error\":\"forbidden\"}"); return; }
    if (method == "OPTIONS") { respond(204, ""); return; }

    if (token != getBrowserToken()) { respond(403, "{\"error\":\"invalid_token\"}"); return; }

    if (url.path() == "/ping") {
        QJsonObject o; o["ok"] = true; o["unlocked"] = isUnlocked();
        respond(200, QJsonDocument(o).toJson(QJsonDocument::Compact));
        return;
    }

    if (url.path() == "/logins") {
        if (!isUnlocked()) { respond(423, "{\"error\":\"locked\"}"); return; }
        QString target = QUrlQuery(url).queryItemValue("host").toLower();
        if (target.startsWith("www.")) target = target.mid(4);

        QJsonArray matches;
        for (const QVariant& v : getAllEntries()) {
            QVariantMap e = v.toMap();
            QString eUrl = e["url"].toString().toLower();
            QString svc = e["service"].toString().toLower();
            QString eHost = QUrl(eUrl.contains("://") ? eUrl : "https://" + eUrl).host();
            if (eHost.startsWith("www.")) eHost = eHost.mid(4);
            bool match = !target.isEmpty() &&
                ((!eHost.isEmpty() && (target == eHost || target.endsWith("." + eHost))) ||
                 (eHost.isEmpty() && !svc.isEmpty() && target.contains(svc)));
            if (!match) continue;
            QJsonObject o;
            o["service"] = e["service"].toString();
            o["username"] = e["username"].toString();
            o["password"] = e["password"].toString();
            matches.append(o);
        }
        respond(200, QJsonDocument(matches).toJson(QJsonDocument::Compact));
        return;
    }

    respond(404, "{\"error\":\"not_found\"}");
}

int VaultManager::getSelfDestructAttempts() {
    QSettings settings;
    return settings.value("selfDestructAttempts", 0).toInt();
}
void VaultManager::setSelfDestructAttempts(int attempts) {
    QSettings settings;
    settings.setValue("selfDestructAttempts", attempts);
    if (attempts == 0) {
        settings.setValue("failedUnlockAttempts", 0);
    }
}
int VaultManager::getFailedAttempts() {
    QSettings settings;
    return settings.value("failedUnlockAttempts", 0).toInt();
}
