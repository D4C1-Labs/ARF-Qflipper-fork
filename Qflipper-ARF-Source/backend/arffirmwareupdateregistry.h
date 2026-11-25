#pragma once

#include "firmwareupdateregistry.h"

#include <QNetworkAccessManager>

namespace Flipper {

class ArfFirmwareUpdateRegistry final : public FirmwareUpdateRegistry
{
    Q_OBJECT

public:
    explicit ArfFirmwareUpdateRegistry(QObject *parent = nullptr);

public slots:
    void check() override;

private:
    static QByteArray buildDirectoryJsonFromRelease(const QJsonObject &releaseObj);

    QNetworkAccessManager m_network;
};

}
