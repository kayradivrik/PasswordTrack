#ifndef VAULTMANAGER_H
#define VAULTMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QByteArray>
#include <QSqlDatabase>
#include <QNetworkAccessManager>
#include <QTimer>
#include <QDateTime>

class QTcpServer;
class QTcpSocket;


#include <openssl/crypto.h>
#ifdef Q_OS_UNIX
#include <sys/mman.h>
#elif defined(Q_OS_WIN)
#include <windows.h>
#endif

class SecureKey {
public:
    SecureKey() : dataPtr(nullptr), keyLen(0) {}
    ~SecureKey() { clear(); }

    SecureKey(const SecureKey&) = delete;
    SecureKey& operator=(const SecureKey&) = delete;

    void set(const QByteArray& keyBytes) {
        clear();
        if (keyBytes.isEmpty()) return;
        
        keyLen = keyBytes.size();
        dataPtr = new char[keyLen];
        memcpy(dataPtr, keyBytes.constData(), keyLen);
        
#include <openssl/crypto.h>
#ifdef Q_OS_UNIX
        mlock(dataPtr, keyLen);
#elif defined(Q_OS_WIN)
        VirtualLock(dataPtr, keyLen);
#endif
    }

    void clear() {
        if (dataPtr) {
            OPENSSL_cleanse(dataPtr, keyLen);
#include <openssl/crypto.h>
#ifdef Q_OS_UNIX
            munlock(dataPtr, keyLen);
#elif defined(Q_OS_WIN)
            VirtualUnlock(dataPtr, keyLen);
#endif
            delete[] dataPtr;
            dataPtr = nullptr;
            keyLen = 0;
        }
    }

    bool isEmpty() const { return dataPtr == nullptr || keyLen == 0; }
    
    QByteArray toByteArray() const {
        if (isEmpty()) return QByteArray();
        return QByteArray::fromRawData(dataPtr, keyLen);
    }
private:
    char* dataPtr;
    size_t keyLen;
};

class VaultManager : public QObject {

    Q_OBJECT
public:
    explicit VaultManager(QObject* parent = nullptr);
    ~VaultManager();

    Q_INVOKABLE bool isSetupRequired();
    Q_INVOKABLE bool setupVault(const QString& masterPassword);
    Q_INVOKABLE bool unlockVault(const QString& masterPassword);
    Q_INVOKABLE void unlockVaultAsync(const QString& masterPassword);
    Q_INVOKABLE void lockVault();
    Q_INVOKABLE bool isUnlocked() const;
    
    // Kapsamlı Veri Yönetimi (Ek Alanlar: URL, Notlar, TOTP, Kategori, Favori)
    Q_INVOKABLE QVariantList getAllEntries();
    Q_INVOKABLE QVariantMap getEntryById(int id);
    Q_INVOKABLE bool addEntry(const QString& service, const QString& username, const QString& password,
                              const QString& url = "", const QString& notes = "", const QString& totpSecret = "",
                              const QString& category = "general", bool isFavorite = false);
    Q_INVOKABLE bool updateEntry(int id, const QString& service, const QString& username, const QString& password,
                                 const QString& url = "", const QString& notes = "", const QString& totpSecret = "",
                                 const QString& category = "general", bool isFavorite = false);
    Q_INVOKABLE bool toggleFavorite(int id);
    Q_INVOKABLE bool deleteEntry(int id);
    Q_INVOKABLE QVariantList getPasswordHistory(int id);
    Q_INVOKABLE void copyToClipboard(const QString& text);
    
    // 2FA / TOTP (Time-based One-Time Password RFC 6238)
    Q_INVOKABLE QString generateTotp(const QString& secret);
    Q_INVOKABLE int getTotpRemainingSeconds();

    // Güvenlik ve Analiz
    Q_INVOKABLE int checkPasswordStrength(const QString& password);
    Q_INVOKABLE void checkPwnedAsync(int id, const QString& plainPassword);
    Q_INVOKABLE void scanVaultForLeaks();
    Q_INVOKABLE QVariantList getLeakedIds();
    Q_INVOKABLE QString getBrowserToken();
    Q_INVOKABLE QString getBrowserExtensionPath();
    Q_INVOKABLE bool isLeakScanning() const;
    Q_INVOKABLE void setScreenshotProtection(bool enabled);
    Q_INVOKABLE void wipeVault();
    Q_INVOKABLE QVariantMap getSecurityReport();
    Q_INVOKABLE bool changeMasterPassword(const QString& currentPassword, const QString& newPassword);

    // Dışa / İçe Aktarma & Kurtarma Kiti & Yedekleme
    Q_INVOKABLE bool exportToCSV(const QString& filePath);
    Q_INVOKABLE QVariantMap importFromCSV(const QString& filePath);
    Q_INVOKABLE bool exportVaultBackup(const QString& filePath);
    Q_INVOKABLE QVariantMap inspectVaultBackup(const QString& filePath);
    Q_INVOKABLE bool restoreVaultBackup(const QString& filePath, bool merge);
    Q_INVOKABLE bool generateEmergencyKit(const QString& filePath);
    Q_INVOKABLE QVariantList getRollingBackups();
    Q_INVOKABLE bool restoreRollingBackup(const QString& backupPath);

    // Ayarlar & Tercihler & Tarayıcı Entegrasyonu
    Q_INVOKABLE QString getWallpaper();
    Q_INVOKABLE void setWallpaper(const QString& path);
    Q_INVOKABLE qreal getWallpaperOpacity();
    Q_INVOKABLE void setWallpaperOpacity(qreal opacity);
    Q_INVOKABLE qreal getUiScale();
    Q_INVOKABLE void setUiScale(qreal scale);
    Q_INVOKABLE QString getLanguage();
    Q_INVOKABLE void setLanguage(const QString& lang);
    Q_INVOKABLE bool hasSelectedLanguage();
    Q_INVOKABLE int getAutoLockMinutes();
    Q_INVOKABLE void setAutoLockMinutes(int minutes);
    Q_INVOKABLE int getSelfDestructAttempts();
    Q_INVOKABLE void setSelfDestructAttempts(int attempts);
    Q_INVOKABLE int getFailedAttempts();
    Q_INVOKABLE bool isBrowserHostRunning() const;
    Q_INVOKABLE void toggleBrowserHost(bool enable);

signals:
    void pwnedStatus(int id, bool isPwned);
    void clipboardCopied(int seconds);
    void clipboardCleared();
    void vaultLocked();
    void totpTick(int remainingSeconds);
    void unlockCompleted(bool success, const QString& errorMsg);
    void leakScanProgress(int current, int total);
    void leakScanFinished(int leakedCount);

protected:
    bool eventFilter(QObject *obj, QEvent *event) override;

private:
    QSqlDatabase db;
    SecureKey encryptionKey;
    QNetworkAccessManager* netManager;

    QTimer* clipboardClearTimer;
    QString lastCopiedPassword;

    QTimer* autoLockCheckTimer;
    QDateTime lastActivityTime;

    QTimer* totpTimer;
    bool leakScanning = false;
    QTcpServer* browserServer = nullptr;

    QString getDatabaseFilePath();
    bool initDatabase();
    void migrateDatabaseIfNeeded();
    QByteArray deriveKey(const QString& password, const QByteArray& salt, int iterations = 600000);
    QByteArray encryptData(const QByteArray& plaintext, const QByteArray& key);
    QByteArray decryptData(const QByteArray& ciphertext, const QByteArray& key);
    void secureZeroMemory(QByteArray& data);
    void createRollingBackup();
    void startBrowserHostServer();
    void stopBrowserHostServer();
    void handleBrowserClient(QTcpSocket* client);
};

#endif // VAULTMANAGER_H
