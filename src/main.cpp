#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QWindow>

#ifdef Q_OS_WIN
#include <windows.h>
#ifndef WDA_EXCLUDEFROMCAPTURE
#define WDA_EXCLUDEFROMCAPTURE 0x00000011
#endif
#endif

#include "VaultManager.h"
#include "PasswordGen.h"

int main(int argc, char *argv[]) {
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QGuiApplication app(argc, argv);
    app.setOrganizationName("KayraPortfolio");
    app.setApplicationName("VoidPass");
    app.setApplicationDisplayName("VoidPass");
    app.setWindowIcon(QIcon(":/icons/shield.svg"));

    VaultManager vaultManager;
    PasswordGen passwordGen;

    QQmlApplicationEngine engine;
    
    // QML'e C++ sınıflarımızı React Component'i / hook'u gibi veriyoruz
    engine.rootContext()->setContextProperty("vaultManager", &vaultManager);
    engine.rootContext()->setContextProperty("passwordGen", &passwordGen);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

#ifdef Q_OS_WIN
    // Anti-Screenshot (Ekran Görüntüsü Koruyucu) Özelliği - Yalnızca Windows'ta
    if (!engine.rootObjects().isEmpty()) {
        if (QWindow *window = qobject_cast<QWindow *>(engine.rootObjects().first())) {
            HWND hwnd = (HWND)window->winId();
            // WDA_EXCLUDEFROMCAPTURE ile pencerenin OBS, Snipping Tool veya virüsler tarafından kaydedilmesini önleriz (Pencere siyah gözükür).
            SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE);
        }
    }
#endif

    return app.exec();
}
