#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickImageProvider>
#include <QQuickWindow>
#include <QIcon>
#include <QProcess>
#include <QProcessEnvironment>
#include <QStandardPaths>
#include <KWindowEffects>
#include <unistd.h>

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
        if (window)
            KWindowEffects::enableBlurBehind(window, true);
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

    // Icon theme: Tela-circle-purple has all distro logos; breeze covers action icons
    {
        QStringList paths = QIcon::themeSearchPaths();
        for (const QString &p : {
                 QStringLiteral("/home/techxero/.local/share/icons"),
                 QStringLiteral("/usr/share/icons"),
                 QStringLiteral("/usr/local/share/icons") }) {
            if (!paths.contains(p)) paths << p;
        }
        QIcon::setThemeSearchPaths(paths);
    }
    QIcon::setThemeName("Tela-circle-purple");
    QIcon::setFallbackThemeName("breeze");

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
