#include "PasswordGen.h"
#include <openssl/rand.h>
#include <cmath>
#include <QSet>

namespace {
// Kriptografik güvenli tarafsız rastgele tam sayı üretici [0, maxExclusive - 1]
int secureRandomInt(int maxExclusive) {
    if (maxExclusive <= 1) return 0;
    unsigned int num = 0;
    unsigned int limit = UINT_MAX - (UINT_MAX % maxExclusive);
    do {
        RAND_bytes(reinterpret_cast<unsigned char*>(&num), sizeof(num));
    } while (num >= limit);
    return num % maxExclusive;
}

const QStringList PASSPHRASE_WORDS = {
    "atlas", "beacon", "breeze", "canyon", "castle", "cipher", "comet", "cosmos",
    "crystal", "dawn", "delta", "desert", "dragon", "eagle", "echo", "ember",
    "falcon", "forest", "galaxy", "glacier", "harbor", "haven", "horizon", "island",
    "jungle", "knight", "lagoon", "lantern", "matrix", "meadow", "meteor", "nebula",
    "nexus", "oasis", "ocean", "orbit", "peak", "phantom", "phoenix", "planet",
    "pulsar", "quantum", "radar", "raven", "ridge", "river", "sapphire", "shadow",
    "shield", "sierra", "signal", "silver", "solar", "spark", "summit", "thunder",
    "titan", "torrent", "valley", "vortex", "voyage", "walnut", "zenith", "zephyr"
};
}

QString PasswordGen::generate(int length, bool upper, bool lower, bool digits, bool symbols) {
    if (length < 4) length = 4;
    if (length > 128) length = 128;

    const QString lowerChars = "abcdefghijklmnopqrstuvwxyz";
    const QString upperChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const QString digitChars = "0123456789";
    const QString symbolChars = "!@#$%^&*()_+-=[]{}|;:,.<>?";

    QString pool;
    QString required;

    if (lower) {
        pool += lowerChars;
        required += lowerChars[secureRandomInt(lowerChars.length())];
    }
    if (upper) {
        pool += upperChars;
        required += upperChars[secureRandomInt(upperChars.length())];
    }
    if (digits) {
        pool += digitChars;
        required += digitChars[secureRandomInt(digitChars.length())];
    }
    if (symbols) {
        pool += symbolChars;
        required += symbolChars[secureRandomInt(symbolChars.length())];
    }

    if (pool.isEmpty()) {
        pool = lowerChars + digitChars;
        required += lowerChars[secureRandomInt(lowerChars.length())];
    }

    QString password = required;
    int remaining = length - password.length();
    for (int i = 0; i < remaining; ++i) {
        password.append(pool[secureRandomInt(pool.length())]);
    }

    // Karakterleri Fisher-Yates karıştırması ile rastgele diz
    for (int i = password.length() - 1; i > 0; --i) {
        int j = secureRandomInt(i + 1);
        QChar temp = password[i];
        password[i] = password[j];
        password[j] = temp;
    }

    return password;
}

QString PasswordGen::generatePassphrase(int wordCount, const QString& separator) {
    if (wordCount < 2) wordCount = 2;
    if (wordCount > 10) wordCount = 10;

    QStringList chosen;
    for (int i = 0; i < wordCount; ++i) {
        int index = secureRandomInt(PASSPHRASE_WORDS.size());
        chosen.append(PASSPHRASE_WORDS[index]);
    }
    // Son kelimeye ekstra 2 basamaklı rastgele sayı ekle
    int randNum = 10 + secureRandomInt(90);
    chosen.last() += QString::number(randNum);

    return chosen.join(separator);
}

int PasswordGen::calculateEntropy(const QString& password) {
    if (password.isEmpty()) return 0;

    int poolSize = 0;
    bool hasLower = false, hasUpper = false, hasDigit = false, hasSymbol = false;
    for (QChar c : password) {
        if (c.isLower()) hasLower = true;
        else if (c.isUpper()) hasUpper = true;
        else if (c.isDigit()) hasDigit = true;
        else hasSymbol = true;
    }

    if (hasLower) poolSize += 26;
    if (hasUpper) poolSize += 26;
    if (hasDigit) poolSize += 10;
    if (hasSymbol) poolSize += 32;

    if (poolSize == 0) return 0;
    double entropy = password.length() * (std::log2(poolSize));
    return static_cast<int>(std::round(entropy));
}
