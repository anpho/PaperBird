APP_NAME = paperbird

CONFIG += qt warn_on cascades10
QT += network
LIBS += -lbbsystem -lbb 
LIBS += -lbbdata
LIBS += -lbbcascadesdatamanager
LIBS += -lbbcascadesmultimedia
include(config.pri)
QT       += sql
RESOURCES += assets.qrc
DEPENDPATH += assets