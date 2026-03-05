#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickImageProvider>
#include <QQuickWindow>
#include <QStyleHints>
#include <QIcon>
#include <QDir>
#include <QStandardPaths>

#include "bootmanager.h"

// Supports pipe-separated fallback names: "icon-a|icon-b|icon-c"
class IconImageProvider : public QQuickImageProvider
{
public:
    IconImageProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {}

    QPixmap requestPixmap(const QString &id, QSize *size,
                          const QSize &requestedSize) override
    {
        QSize s = (requestedSize.isValid() && requestedSize.width() > 0)
                  ? requestedSize : QSize(24, 24);
        if (size) *size = s;

        QIcon icon;
        for (const QString &name : id.split('|', Qt::SkipEmptyParts)) {
            icon = QIcon::fromTheme(name.trimmed());
            if (!icon.isNull()) break;
        }
        if (icon.isNull())
            icon = QIcon::fromTheme("drive-harddisk");

        return icon.isNull() ? QPixmap() : icon.pixmap(s);
    }
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("xero");
    app.setApplicationName("EfiBootMgrGUI");
    app.setApplicationVersion("1.0.0");

    // Tell the compositor this app wants dark window decorations
    app.styleHints()->setColorScheme(Qt::ColorScheme::Dark);

    // Build icon search paths from XDG standard locations (safe for any user/DE)
    {
        QStringList paths = QIcon::themeSearchPaths();
        const auto dataDirs = QStandardPaths::standardLocations(
            QStandardPaths::GenericDataLocation);
        for (const QString &dir : dataDirs) {
            const QString iconDir = dir + "/icons";
            if (!paths.contains(iconDir))
                paths << iconDir;
        }
        QIcon::setThemeSearchPaths(paths);
    }

    // Use Tela-circle-purple only if it is actually installed
    for (const QString &path : QIcon::themeSearchPaths()) {
        if (QDir(path + "/Tela-circle-purple").exists()) {
            QIcon::setThemeName("Tela-circle-purple");
            QIcon::setFallbackThemeName("breeze");
            break;
        }
    }

    qmlRegisterType<BootManager>("com.efibootmgrgui", 1, 0, "BootManager");

    QQmlApplicationEngine engine;
    engine.addImageProvider("icon", new IconImageProvider());

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { qFatal("QML object creation failed"); }, Qt::QueuedConnection);

    engine.load(QUrl("qrc:/com/efibootmgrgui/qml/main.qml"));

    if (engine.rootObjects().isEmpty())
        return 1;

    return app.exec();
}
