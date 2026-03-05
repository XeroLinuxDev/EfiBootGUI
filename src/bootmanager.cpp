#include "bootmanager.h"

#include <QRegularExpression>
#include <functional>

BootManager::BootManager(QObject *parent)
    : QAbstractListModel(parent)
{
    refresh();
}

// ---------------------------------------------------------------------------
// QAbstractListModel
// ---------------------------------------------------------------------------

int BootManager::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_entries.size();
}

QVariant BootManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};
    const auto &e = m_entries.at(index.row());
    switch (role) {
    case BootNumRole:    return e.bootNum;
    case NameRole:       return e.name;
    case ActiveRole:     return e.active;
    case IsBootNextRole: return e.isBootNext;
    case IsCurrentRole:  return e.isCurrent;
    default:             return {};
    }
}

QHash<int, QByteArray> BootManager::roleNames() const
{
    return {
        { BootNumRole,    "bootNum"    },
        { NameRole,       "name"       },
        { ActiveRole,     "active"     },
        { IsBootNextRole, "isBootNext" },
        { IsCurrentRole,  "isCurrent"  },
    };
}

// ---------------------------------------------------------------------------
// Public slots
// ---------------------------------------------------------------------------

void BootManager::refresh()
{
    appendLog("Running efibootmgr...");
    runEfibootmgr({}, [this](int code, const QString &out) {
        if (code != 0) {
            appendLog("efibootmgr failed (exit " + QString::number(code) + "). Are you root?");
            emit operationFinished(false, "efibootmgr failed. Authentication may have been cancelled.");
            return;
        }
        parseOutput(out);
        appendLog("Loaded " + QString::number(m_entries.size()) + " boot entries.");
        emit operationFinished(true, "Refreshed.");
    });
}

void BootManager::setActive(const QString &bootNum, bool active)
{
    // active   → --active   --bootnum XXXX
    // inactive → --inactive --bootnum XXXX
    QStringList args = { active ? "--active" : "--inactive",
                         "--bootnum", bootNum };
    appendLog((active ? "Enabling " : "Disabling ") + bootNum);
    runEfibootmgr(args, [this](int code, const QString &) {
        if (code == 0) refresh();
        else emit operationFinished(false, "Failed to change active state.");
    });
}

void BootManager::deleteEntry(const QString &bootNum)
{
    appendLog("Deleting Boot" + bootNum);
    runEfibootmgr({ "--delete-bootnum", "--bootnum", bootNum },
                  [this](int code, const QString &) {
        if (code == 0) refresh();
        else emit operationFinished(false, "Failed to delete entry.");
    });
}

void BootManager::moveUp(int index)
{
    if (index <= 0 || index >= m_orderList.size()) return;
    m_orderList.swapItemsAt(index, index - 1);
    emit bootOrderChanged();

    // Mirror in m_entries for visual feedback before applyBootOrder
    beginMoveRows({}, index, index, {}, index - 1);
    m_entries.swapItemsAt(index, index - 1);
    endMoveRows();
}

void BootManager::moveDown(int index)
{
    if (index < 0 || index >= m_orderList.size() - 1) return;
    m_orderList.swapItemsAt(index, index + 1);
    emit bootOrderChanged();

    beginMoveRows({}, index + 1, index + 1, {}, index);
    m_entries.swapItemsAt(index, index + 1);
    endMoveRows();
}

void BootManager::applyBootOrder()
{
    if (m_orderList.isEmpty()) return;
    QString order = m_orderList.join(",");
    appendLog("Setting BootOrder: " + order);
    runEfibootmgr({ "--bootorder", order }, [this](int code, const QString &) {
        if (code == 0) {
            appendLog("Boot order applied.");
            emit operationFinished(true, "Boot order saved.");
            refresh();
        } else {
            emit operationFinished(false, "Failed to set boot order.");
        }
    });
}

void BootManager::setBootNext(const QString &bootNum)
{
    appendLog("Setting BootNext to Boot" + bootNum);
    runEfibootmgr({ "--bootnext", bootNum }, [this](int code, const QString &) {
        if (code == 0) refresh();
        else emit operationFinished(false, "Failed to set BootNext.");
    });
}

void BootManager::clearBootNext()
{
    appendLog("Clearing BootNext");
    runEfibootmgr({ "--delete-bootnext" }, [this](int code, const QString &) {
        if (code == 0) refresh();
        else emit operationFinished(false, "Failed to clear BootNext.");
    });
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

void BootManager::runEfibootmgr(const QStringList &args,
                                 std::function<void(int, const QString &)> callback)
{
    setLoading(true);

    auto *proc = new QProcess(this);

    // Use pkexec so the app runs unprivileged; polkit handles auth once per
    // session (auth_admin_keep policy). Works on KDE, GNOME, COSMIC, etc.
    QString program      = "pkexec";
    QStringList fullArgs = QStringList{"/usr/bin/efibootmgr"} + args;

    connect(proc, &QProcess::finished, this,
            [this, proc, callback](int exitCode, QProcess::ExitStatus) {
        setLoading(false);
        QString out = proc->readAllStandardOutput();
        QString err = proc->readAllStandardError();
        if (!err.isEmpty()) appendLog("[stderr] " + err.trimmed());
        callback(exitCode, out);
        proc->deleteLater();
    });

    connect(proc, &QProcess::errorOccurred, this,
            [this, proc, callback](QProcess::ProcessError err) {
        setLoading(false);
        appendLog("Process error: " + proc->errorString());
        callback(-1, {});
        proc->deleteLater();
    });

    proc->start(program, fullArgs);
}

void BootManager::parseOutput(const QString &output)
{
    beginResetModel();
    m_entries.clear();
    m_orderList.clear();
    m_bootOrder.clear();

    // BootCurrent: 0002
    // Timeout: 3 seconds
    // BootOrder: 0002,0000,0001
    // Boot0000* ubuntu
    // Boot0001  Windows Boot Manager
    // Boot0002* UEFI Shell

    static const QRegularExpression reOrder(R"(^BootOrder:\s*(.+)$)",
                                            QRegularExpression::MultilineOption);
    static const QRegularExpression reEntry(R"(^Boot([0-9A-Fa-f]{4})(\*?)\s+(.+)$)",
                                            QRegularExpression::MultilineOption);

    auto mOrder = reOrder.match(output);
    if (mOrder.hasMatch()) {
        m_bootOrder = mOrder.captured(1).trimmed();
        m_orderList = m_bootOrder.split(',', Qt::SkipEmptyParts);
    }

    // Collect all entries in a map first
    QMap<QString, BootEntry> entryMap;
    auto it = reEntry.globalMatch(output);
    while (it.hasNext()) {
        auto m = it.next();
        BootEntry e;
        e.bootNum    = m.captured(1).toUpper();
        e.active     = (m.captured(2) == "*");
        // efibootmgr separates the name from device path with either:
        //   a real tab (\t), or box-drawing chars (├──┤, U+251C...U+2524)
        // Take whichever delimiter comes first.
        QString raw = m.captured(3);
        int tabPos  = raw.indexOf(QLatin1Char('\t'));
        int boxPos  = raw.indexOf(QChar(0x251C)); // ├
        int cut = -1;
        if (tabPos >= 0 && boxPos >= 0) cut = qMin(tabPos, boxPos);
        else if (tabPos >= 0)           cut = tabPos;
        else if (boxPos >= 0)           cut = boxPos;
        e.name = (cut >= 0 ? raw.left(cut) : raw).trimmed();
        e.isBootNext = false;
        e.isCurrent  = false;
        entryMap.insert(e.bootNum, e);
    }

    // Check BootCurrent
    static const QRegularExpression reCurrent(R"(^BootCurrent:\s*([0-9A-Fa-f]{4})$)",
                                               QRegularExpression::MultilineOption);
    auto mCurrent = reCurrent.match(output);
    if (mCurrent.hasMatch()) {
        QString curNum = mCurrent.captured(1).toUpper();
        if (entryMap.contains(curNum))
            entryMap[curNum].isCurrent = true;
    }

    // Check BootNext
    static const QRegularExpression reNext(R"(^BootNext:\s*([0-9A-Fa-f]{4})$)",
                                           QRegularExpression::MultilineOption);
    auto mNext = reNext.match(output);
    if (mNext.hasMatch()) {
        QString nextNum = mNext.captured(1).toUpper();
        if (entryMap.contains(nextNum))
            entryMap[nextNum].isBootNext = true;
    }

    // Populate m_entries in BootOrder sequence first, then remaining
    for (const QString &num : m_orderList) {
        QString key = num.trimmed().toUpper();
        if (entryMap.contains(key)) {
            m_entries.append(entryMap.take(key));
        }
    }
    // Append entries not in BootOrder
    for (const auto &e : entryMap)
        m_entries.append(e);

    endResetModel();
    emit bootOrderChanged();
}

void BootManager::appendLog(const QString &line)
{
    if (!m_log.isEmpty()) m_log += '\n';
    m_log += line;
    emit logChanged();
}

void BootManager::setLoading(bool v)
{
    if (m_loading == v) return;
    m_loading = v;
    emit loadingChanged();
}
