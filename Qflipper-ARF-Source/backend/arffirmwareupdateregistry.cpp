#include "arffirmwareupdateregistry.h"

#include <QDateTime>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLoggingCategory>
#include <QNetworkReply>
#include <QRegularExpression>
#include <QTimer>

Q_LOGGING_CATEGORY(CATEGORY_ARF_UPDATES, "ARF")

using namespace Flipper;

namespace {

QString stripVersionTag(const QString &tag)
{
    if(tag.startsWith(QLatin1Char('v')) || tag.startsWith(QLatin1Char('V'))) {
        return tag.mid(1);
    }
    return tag;
}

} // namespace

ArfFirmwareUpdateRegistry::ArfFirmwareUpdateRegistry(QObject *parent):
    FirmwareUpdateRegistry(QStringLiteral(""), parent)
{}

void ArfFirmwareUpdateRegistry::check()
{
    setState(UpdateRegistry::State::Checking);

    const QUrl url(QStringLiteral("https://api.github.com/repos/D4C1-Labs/Flipper-ARF/releases/latest"));
    QNetworkRequest req(url);
    req.setRawHeader(QByteArrayLiteral("User-Agent"), QByteArrayLiteral("ARF-qFlipper"));
    req.setRawHeader(QByteArrayLiteral("Accept"), QByteArrayLiteral("application/vnd.github+json"));

    auto *reply = m_network.get(req);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();

        if(reply->error() != QNetworkReply::NoError) {
            qCCritical(CATEGORY_ARF_UPDATES).noquote()
                << "ARF firmware release fetch failed:" << reply->errorString();
            setState(UpdateRegistry::State::ErrorOccured);
            m_checkTimer->start(std::chrono::minutes(10));
            return;
        }

        const auto doc = QJsonDocument::fromJson(reply->readAll());
        if(!doc.isObject()) {
            qCCritical(CATEGORY_ARF_UPDATES) << "ARF: invalid JSON from GitHub releases API";
            setState(UpdateRegistry::State::ErrorOccured);
            m_checkTimer->start(std::chrono::minutes(10));
            return;
        }

        const auto json = buildDirectoryJsonFromRelease(doc.object());
        if(json.isEmpty()) {
            qCCritical(CATEGORY_ARF_UPDATES) << "ARF: could not build firmware directory (missing .tgz asset?)";
            setState(UpdateRegistry::State::ErrorOccured);
            m_checkTimer->start(std::chrono::minutes(10));
            return;
        }

        fillFromJson(json);
        setState(channelNames().isEmpty() ? UpdateRegistry::State::ErrorOccured : UpdateRegistry::State::Ready);
        m_checkTimer->start(std::chrono::minutes(10));
    });
}

QByteArray ArfFirmwareUpdateRegistry::buildDirectoryJsonFromRelease(const QJsonObject &releaseObj)
{
    const auto tagName = releaseObj.value(QStringLiteral("tag_name")).toString();
    const auto body = releaseObj.value(QStringLiteral("body")).toString();
    const auto publishedAt = releaseObj.value(QStringLiteral("published_at")).toString();

    const auto published = QDateTime::fromString(publishedAt, Qt::ISODate);
    const qint64 ts = published.isValid() ? published.toSecsSinceEpoch() : QDateTime::currentSecsSinceEpoch();

    QString tgzUrl;
    const auto assets = releaseObj.value(QStringLiteral("assets")).toArray();
    static const QRegularExpression tgzSuffix(QStringLiteral("\\.tgz$"), QRegularExpression::CaseInsensitiveOption);

    for(const auto &assetVal : assets) {
        const auto asset = assetVal.toObject();
        const auto name = asset.value(QStringLiteral("name")).toString();
        const auto url = asset.value(QStringLiteral("browser_download_url")).toString();
        if(tgzSuffix.match(name).hasMatch() && !url.isEmpty()) {
            tgzUrl = url;
            break;
        }
    }

    if(tgzUrl.isEmpty()) {
        return {};
    }

    const QString version = stripVersionTag(tagName);

    QJsonObject fileObj{
        { QStringLiteral("target"), QStringLiteral("f7") },
        { QStringLiteral("type"), QStringLiteral("update_tgz") },
        { QStringLiteral("url"), tgzUrl },
        { QStringLiteral("sha256"), QString() },
    };

    QJsonObject versionObj{
        { QStringLiteral("version"), version },
        { QStringLiteral("changelog"), body },
        { QStringLiteral("timestamp"), ts },
        { QStringLiteral("files"), QJsonArray{ fileObj } },
    };

    QJsonObject channelObj{
        { QStringLiteral("id"), QStringLiteral("arf") },
        { QStringLiteral("title"), QStringLiteral("ARF Firmware") },
        { QStringLiteral("description"), QStringLiteral("Latest ARF firmware from GitHub releases") },
        { QStringLiteral("versions"), QJsonArray{ versionObj } },
    };

    QJsonObject root{
        { QStringLiteral("channels"), QJsonArray{ channelObj } },
    };

    return QJsonDocument(root).toJson(QJsonDocument::Compact);
}
