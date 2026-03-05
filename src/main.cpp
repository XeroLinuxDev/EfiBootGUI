#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickImageProvider>
#include <QQuickWindow>
#include <QIcon>
#include <QDir>
#include <QProcess>
#include <QProcessEnvironment>
#include <QStandardPaths>
#include <unistd.h>

#ifdef HAVE_KWINDOWSYSTEM
#include <KWindowEffects>
#endif

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

class AppHelper : public QObject
{
    Q_OBJECT
public:
    explicit AppHelper(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE void relaunchAsRoot()
    {
        QString exe = QCoreApplication::applicationFilePath();

        if (!QStandardPaths::findExecutable("kdesu").isEmpty()) {
            QProcess::startDetached("kdesu", { "-c", exe });
            QCoreApplication::quit();
            return;
        }

        QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
        QProcess::startDetached("pkexec", {
            "env",
            "DISPLAY="         + env.value("DISPLAY"),
            "WAYLAND_DISPLAY=" + env.value("WAYLAND_DISPLAY"),
            "XDG_RUNTIME_DIR=" + env.value("XDG_RUNTIME_DIR"),
            exe
        });
        QCoreApplication::quit();
    }
};

class BlurHelper : public QObject
{
    Q_OBJECT
public:
    explicit BlurHelper(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE void enableBlur(QQuickWindow *window)
    {
#ifdef HAVE_KWINDOWSYSTEM
        if (!window) return;
        if (KWindowEffects::isEffectAvailable(KWindowEffects::BlurBehind))
            KWindowEffects::enableBlurBehind(window, true);
#else
        Q_UNUSED(window)
#endif
    }
};

#include "main.moc"

static void autoElevate()
{
    QString exe = QCoreApplication::applicationFilePath();

    if (!QStandardPaths::findExecutable("kdesu").isEmpty()) {
        QProcess::startDetached("kdesu", { "-c", exe });
        return;
    }

    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    QProcess::startDetached("pkexec", {
        "env",
        "DISPLAY="         + env.value("DISPLAY"),
        "WAYLAND_DISPLAY=" + env.value("WAYLAND_DISPLAY"),
        "XDG_RUNTIME_DIR=" + env.value("XDG_RUNTIME_DIR"),
        exe
    });
}

int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("xero");
    app.setApplicationName("EfiBootMgrGUI");
    app.setApplicationVersion("1.0.0");

    // Auto-elevate on launch if not root
    if (getuid() != 0) {
        autoElevate();
        return 0;
    }

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
    bool telaFound = false;
    for (const QString &path : QIcon::themeSearchPaths()) {
        if (QDir(path + "/Tela-circle-purple").exists()) {
            telaFound = true;
            break;
        }
    }
    if (telaFound) {
        QIcon::setThemeName("Tela-circle-purple");
        QIcon::setFallbackThemeName("breeze");
    }

    qmlRegisterType<BootManager>("com.efibootmgrgui", 1, 0, "BootManager");

    AppHelper  appHelper;
    BlurHelper blurHelper;

    QQmlApplicationEngine engine;
    engine.addImageProvider("icon", new IconImageProvider());
    engine.rootContext()->setContextProperty("appHelper",  &appHelper);
    engine.rootContext()->setContextProperty("blurHelper", &blurHelper);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [&blurHelper](QObject *obj, const QUrl &) {
            if (!obj) return;
            auto *window = qobject_cast<QQuickWindow *>(obj);
            if (window) blurHelper.enableBlur(window);
        }, Qt::QueuedConnection);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { qFatal("QML object creation failed"); }, Qt::QueuedConnection);

    engine.load(QUrl("qrc:/com/efibootmgrgui/qml/main.qml"));

    if (engine.rootObjects().isEmpty())
        return 1;

    return app.exec();
}
