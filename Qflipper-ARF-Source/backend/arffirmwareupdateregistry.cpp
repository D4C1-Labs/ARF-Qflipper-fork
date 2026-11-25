#include "arffirmwareupdateregistry.h"

#include <QDateTime>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLoggingCategory>
#include <QNetworkReply>
#include <QTimer>

Q_LOGGING_CATEGORY(CATEGORY_ARF_UPDATES, "OCF")

using namespace Flipper;

ArfFirmwareUpdateRegistry::ArfFirmwareUpdateRegistry(QObject *parent):
    FirmwareUpdateRegistry(QStringLiteral(""), parent)
{}

void ArfFirmwareUpdateRegistry::check()
{
    setState(UpdateRegistry::State::Checking);

    const QUrl url(QStringLiteral("https://ARF-firmware.vercel.app/api/package?file=firmware"));
    QNetworkRequest req(url);
    req.setRawHeader(QByteArrayLiteral("User-Agent"), QByteArrayLiteral("ARF-Flipper"));
    req.setRawHeader(QByteArrayLiteral("Accept"), QByteArrayLiteral("*/*"));

    auto *reply = m_network.get(req);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();

        if(reply->error() != QNetworkReply::NoError) {
            qCCritical(CATEGORY_ARF_UPDATES).noquote()
                << "ARF firmware endpoint fetch failed:" << reply->errorString();
            setState(UpdateRegistry::State::ErrorOccured);
            m_checkTimer->start(std::chrono::minutes(10));
            return;
        }

        const auto json = buildDirectoryJsonFromRelease(QJsonObject{});
        if(json.isEmpty()) {
            qCCritical(CATEGORY_ARF_UPDATES) << "ARF: could not build firmware directory";
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
    Q_UNUSED(releaseObj);
    const qint64 ts = QDateTime::currentSecsSinceEpoch();
    const QString tgzUrl = QStringLiteral("https://ARF-firmware.vercel.app/downloads/ARF-firmware-update.tgz");
    const QString version = QStringLiteral("1.0");
    const QString body = QStringLiteral("ARF LAST DEV - First Release");

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
        { QStringLiteral("id"), QStringLiteral("ARF") },
        { QStringLiteral("title"), QStringLiteral("ARF LAST DEV") },
        { QStringLiteral("description"), QStringLiteral("Firmware delivered by ARF-firmware.vercel.app") },
        { QStringLiteral("versions"), QJsonArray{ versionObj } },
    };

    QJsonObject root{
        { QStringLiteral("channels"), QJsonArray{ channelObj } },
    };

    return QJsonDocument(root).toJson(QJsonDocument::Compact);
}
