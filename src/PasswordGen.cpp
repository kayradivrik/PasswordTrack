#include "PasswordGen.h"
#include <random>

QString PasswordGen::generate(int length) {
    const QString chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?";
    std::random_device rd;
    std::mt19937 generator(rd());
    std::uniform_int_distribution<int> distribution(0, chars.length() - 1);

    QString password;
    for (int i = 0; i < length; ++i) {
        password.append(chars[distribution(generator)]);
    }
    return password;
}
