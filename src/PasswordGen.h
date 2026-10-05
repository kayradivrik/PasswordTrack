#ifndef PASSWORDGEN_H
#define PASSWORDGEN_H

#include <QObject>
#include <QString>
#include <QStringList>

class PasswordGen : public QObject {
    Q_OBJECT
public:
    explicit PasswordGen(QObject* parent = nullptr) : QObject(parent) {}

    // Kriptografik Olarak Güvenli (CSPRNG - OpenSSL RAND_bytes) Parola Üretimi
    Q_INVOKABLE QString generate(int length = 16, bool upper = true, bool lower = true, bool digits = true, bool symbols = true);
    Q_INVOKABLE QString generatePassphrase(int wordCount = 4, const QString& separator = "-");
    Q_INVOKABLE int calculateEntropy(const QString& password);
};

#endif // PASSWORDGEN_H
