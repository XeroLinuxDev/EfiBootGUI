#pragma once

#include <QAbstractListModel>
#include <QProcess>
#include <QString>
#include <QStringList>
#include <QVector>
#include "bootentry.h"

class BootManager : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool   loading   READ loading   NOTIFY loadingChanged)
    Q_PROPERTY(QString bootOrder READ bootOrder NOTIFY bootOrderChanged)
    Q_PROPERTY(QString log      READ log       NOTIFY logChanged)

public:
    enum Roles {
        BootNumRole = Qt::UserRole + 1,
        NameRole,
        ActiveRole,
        IsBootNextRole,
        IsCurrentRole
    };

    explicit BootManager(QObject *parent = nullptr);

    // QAbstractListModel
    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool    loading()   const { return m_loading; }
    QString bootOrder() const { return m_bootOrder; }
    QString log()       const { return m_log; }

public slots:
    void refresh();
    void setActive(const QString &bootNum, bool active);
    void deleteEntry(const QString &bootNum);
    void moveUp(int index);
    void moveDown(int index);
    void applyBootOrder();
    void setBootNext(const QString &bootNum);
    void clearBootNext();

signals:
    void loadingChanged();
    void bootOrderChanged();
    void logChanged();
    void operationFinished(bool success, const QString &message);

private:
    void runEfibootmgr(const QStringList &args,
                       std::function<void(int, const QString &)> callback);
    void parseOutput(const QString &output);
    void appendLog(const QString &line);
    void setLoading(bool v);

    QVector<BootEntry> m_entries;
    QStringList        m_orderList; // ordered boot nums
    QString            m_bootOrder;
    QString            m_log;
    bool               m_loading   = false;
};
