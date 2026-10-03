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

class VaultManager : public QObject {
    Q_OBJECT
public:
    explicit VaultManager(QObject* parent = nullptr);
    ~VaultManager();

    Q_INVOKABLE bool isSetupRequired();
    Q_INVOKABLE bool setupVault(const QString& masterPassword);
    Q_INVOKABLE bool unlockVault(const QString& masterPassword);
    Q_INVOKABLE void lockVault();
    Q_INVOKABLE bool isUnlocked() const;
    
    Q_INVOKABLE QVariantList getAllEntries();
    Q_INVOKABLE bool addEntry(const QString& service, const QString& username, const QString& password);
    Q_INVOKABLE bool updateEntry(int id, const QString& service, const QString& username, const QString& password);
    Q_INVOKABLE bool deleteEntry(int id);
    Q_INVOKABLE void copyToClipboard(const QString& text);
    
    Q_INVOKABLE int checkPasswordStrength(const QString& password);
    Q_INVOKABLE void checkPwnedAsync(int id, const QString& plainPassword);
    Q_INVOKABLE void setScreenshotProtection(bool enabled);
    Q_INVOKABLE void wipeVault();
    Q_INVOKABLE QString getWallpaper();
    Q_INVOKABLE void setWallpaper(const QString& path);
    Q_INVOKABLE qreal getWallpaperOpacity();
    Q_INVOKABLE void setWallpaperOpacity(qreal opacity);
    Q_INVOKABLE qreal getUiScale();
    Q_INVOKABLE void setUiScale(qreal scale);

    Q_INVOKABLE bool exportToCSV(const QString& filePath);
    Q_INVOKABLE bool exportVaultBackup(const QString& filePath);
    Q_INVOKABLE QVariantMap inspectVaultBackup(const QString& filePath);
    Q_INVOKABLE bool restoreVaultBackup(const QString& filePath, bool merge);
    Q_INVOKABLE int getAutoLockMinutes();
    Q_INVOKABLE void setAutoLockMinutes(int minutes);
    Q_INVOKABLE QVariantMap getSecurityReport();
    Q_INVOKABLE bool changeMasterPassword(const QString& currentPassword, const QString& newPassword);

signals:
    void pwnedStatus(int id, bool isPwned);
    void clipboardCopied(int seconds);
    void clipboardCleared();
    void vaultLocked();

protected:
    bool eventFilter(QObject *obj, QEvent *event) override;

private:
    QSqlDatabase db;
    QByteArray encryptionKey;
    QNetworkAccessManager* netManager;

    QTimer* clipboardClearTimer;
    QString lastCopiedPassword;

    QTimer* autoLockCheckTimer;
    QDateTime lastActivityTime;

    bool initDatabase();
    QByteArray deriveKey(const QString& password, const QByteArray& salt);
    QByteArray encryptData(const QByteArray& plaintext, const QByteArray& key);
    QByteArray decryptData(const QByteArray& ciphertext, const QByteArray& key);
};

#endif // VAULTMANAGER_H
