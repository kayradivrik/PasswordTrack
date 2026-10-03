#ifndef PASSWORDGEN_H
#define PASSWORDGEN_H

#include <QObject>
#include <QString>

class PasswordGen : public QObject {
    Q_OBJECT
public:
    explicit PasswordGen(QObject* parent = nullptr) : QObject(parent) {}
    Q_INVOKABLE QString generate(int length = 16);
};

#endif // PASSWORDGEN_H
