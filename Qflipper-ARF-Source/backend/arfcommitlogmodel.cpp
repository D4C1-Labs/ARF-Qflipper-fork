#include "arfcommitlogmodel.h"

#include <QDateTime>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLoggingCategory>
#include <QNetworkReply>
#include <QUrl>

Q_LOGGING_CATEGORY(CATEGORY_ARF_COMMITS, "ARF")

ArfCommitLogModel::ArfCommitLogModel(QObject *parent):
    QAbstractListModel(parent)
{}

int ArfCommitLogModel::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid()) {
        return 0;
    }
    return m_entries.size();
}

QVariant ArfCommitLogModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid() || index.row() >= m_entries.size()) {
        return {};
    }

    const auto &e = m_entries.at(index.row());
    switch(role) {
    case MessageRole:
        return e.message;
    case AuthorRole:
        return e.author;
    case DateRole:
        return e.date;
    default:
        return {};
    }
}

QHash<int, QByteArray> ArfCommitLogModel::roleNames() const
{
    return {
        { MessageRole, QByteArrayLiteral("message") },
        { AuthorRole, QByteArrayLiteral("author") },
        { DateRole, QByteArrayLiteral("date") },
    };
}

void ArfCommitLogModel::refresh()
{
    if(m_reply) {
        return;
    }

    emit refreshStarted();

    const QUrl url(QStringLiteral("https://api.github.com/repos/D4C1-Labs/Flipper-ARF/commits?per_page=40"));
    QNetworkRequest req(url);
    req.setRawHeader(QByteArrayLiteral("User-Agent"), QByteArrayLiteral("ARF-qFlipper"));
    req.setRawHeader(QByteArrayLiteral("Accept"), QByteArrayLiteral("application/vnd.github+json"));

    m_reply = m_network.get(req);
    connect(m_reply, &QNetworkReply::finished, this, &ArfCommitLogModel::onNetworkFinished);
}

void ArfCommitLogModel::onNetworkFinished()
{
    if(!m_reply) {
        return;
    }

    m_reply->deleteLater();
    auto *reply = m_reply;
    m_reply = nullptr;

    if(reply->error() != QNetworkReply::NoError) {
        const auto err = reply->errorString();
        qCCritical(CATEGORY_ARF_COMMITS).noquote() << "ARF commits fetch failed:" << err;
        emit refreshFinished(false, err);
        return;
    }

    const auto doc = QJsonDocument::fromJson(reply->readAll());
    if(!doc.isArray()) {
        emit refreshFinished(false, QStringLiteral("Invalid response"));
        return;
    }

    QVector<Entry> next;
    const auto arr = doc.array();
    next.reserve(arr.size());

    for(const auto &val : arr) {
        const auto obj = val.toObject();
        const auto commit = obj.value(QStringLiteral("commit")).toObject();
        const auto msg = commit.value(QStringLiteral("message")).toString().split(QLatin1Char('\n')).first();
        const auto authorObj = commit.value(QStringLiteral("author")).toObject();
        const auto authorName = authorObj.value(QStringLiteral("name")).toString();
        const auto dateStr = authorObj.value(QStringLiteral("date")).toString();
        const auto dt = QDateTime::fromString(dateStr, Qt::ISODate);
        const auto dateFormatted = dt.isValid() ? dt.toLocalTime().toString(Qt::ISODateWithMs) : dateStr;

        next.append({ msg, authorName, dateFormatted });
    }

    beginResetModel();
    m_entries = std::move(next);
    endResetModel();

    emit refreshFinished(true, QString());
}
