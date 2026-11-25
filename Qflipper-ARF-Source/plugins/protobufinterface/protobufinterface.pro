QT -= gui

TEMPLATE = lib
CONFIG += staticlib

requires(false)

HEADERS += \
    bandinfo.h \
    guiresponseinterface.h \
    mainresponseinterface.h \
    propertyresponseinterface.h \
    protobufplugininterface.h \
    statusresponseinterface.h \
    storageresponseinterface.h \
    systemresponseinterface.h
