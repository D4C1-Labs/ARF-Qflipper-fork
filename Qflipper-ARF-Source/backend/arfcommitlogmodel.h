#pragma once

#include <QAbstractListModel>
#include <QNetworkAccessManager>

class ArfCommitLogModel final : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        MessageRole = Qt::UserRole + 1,
        AuthorRole,
        DateRole,
    };

    explicit ArfCommitLogModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void refresh();

signals:
    void refreshStarted();
    void refreshFinished(bool success, const QString &errorMessage);

private slots:
    void onNetworkFinished();

private:
    struct Entry {
        QString message;
        QString author;
        QString date;
    };

    QNetworkAccessManager m_network;
    QNetworkReply *m_reply = nullptr;
    QVector<Entry> m_entries;
};
