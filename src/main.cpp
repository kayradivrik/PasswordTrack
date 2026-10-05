#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QWindow>
#include <QLocalServer>
#include <QLocalSocket>

#ifdef Q_OS_WIN
#include <windows.h>
#ifndef WDA_EXCLUDEFROMCAPTURE
#define WDA_EXCLUDEFROMCAPTURE 0x00000011
#endif
#endif

#include <QFont>
#include "VaultManager.h"
#include "PasswordGen.h"

int main(int argc, char *argv[]) {
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QGuiApplication app(argc, argv);
    QFont defaultFont("Segoe UI", 10);
    defaultFont.setStyleHint(QFont::SansSerif);
    app.setFont(defaultFont);

    app.setOrganizationName("KayraPortfolio");
    app.setApplicationName("VoidPass");
    app.setApplicationDisplayName("VoidPass");
    app.setWindowIcon(QIcon(":/icons/logo.png"));

    // Tekil uygulama (single-instance): ikinci başlatmada mevcut pencereyi öne getir
    const QString serverName = "VoidPass_SingleInstance_Lock";
    {
        QLocalSocket probe;
        probe.connectToServer(serverName);
        if (probe.waitForConnected(300)) {
            probe.write("raise");
            probe.waitForBytesWritten(300);
            probe.disconnectFromServer();
            return 0;
        }
    }
    QLocalServer::removeServer(serverName); // çökmüş eski örneğin artığını temizle
    QLocalServer instanceServer;
    instanceServer.listen(serverName);

    VaultManager vaultManager;
    PasswordGen passwordGen;

    QQmlApplicationEngine engine;

    QObject::connect(&instanceServer, &QLocalServer::newConnection, &app, [&]() {
        while (QLocalSocket *s = instanceServer.nextPendingConnection()) {
            s->waitForReadyRead(100);
            s->deleteLater();
        }
        for (QObject *root : engine.rootObjects()) {
            if (QWindow *w = qobject_cast<QWindow *>(root)) {
                w->show();
                if (w->windowStates() & Qt::WindowMinimized)
                    w->setWindowStates(w->windowStates() & ~Qt::WindowMinimized);
                w->raise();
                w->requestActivate();
            }
        }
    });
    
    // QML arayüzüne backend sınıflarımı (VaultManager, PasswordGen) enjekte ediyorum.
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
    // Anti-Screenshot (Ekran Görüntüsü Koruyucu) özelliğini aktifleştiriyorum. Sadece Windows'ta çalışıyor.
    if (!engine.rootObjects().isEmpty()) {
        if (QWindow *window = qobject_cast<QWindow *>(engine.rootObjects().first())) {
            HWND hwnd = (HWND)window->winId();
            // Ekran kaydedicilerin (OBS, Snipping Tool, zararlı yazılımlar) pencereyi kaydetmesini engelliyorum.
            SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE);
        }
    }
#endif

    return app.exec();
}
