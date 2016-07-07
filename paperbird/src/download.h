#ifndef DOWNLOAD_H
#define DOWNLOAD_H

#include <QObject>
#include <QList>
#include <QUrl>
#include <QQueue>
#include <QFile>
#include <QMap>
#include <QNetworkAccessManager>

class QNetworkReply;

struct Queue{
  QString key;
  QUrl url;
};

class Download : public QObject{

  Q_OBJECT

public:
  Download(QObject * parent  = 0);
  ~Download();

  void append(const QUrl & url);
  void append(const QStringList & urlList);

private slots:
  void startNextDownload();
  void downloadProgress(qint64 bytes, qint64 bytesTotal);
  void downloadReadyRead();
  void downloadFinished();
  
signals:
  void finished();

private:
  QString saveFileName(const QUrl & url);
  QString getUuid(const QString & str = "");
  QString getPartFileName(const QString & filename, const QString & key = "");
  QString getOriginalFilename(const QString & filename, const QString & key);

private:
  QNetworkAccessManager manager;
  QQueue<Queue> downloadQueue;
  QList<QUrl> downloadBatch;
  int totalCount;
  
  QMap<QString, QFile *> files;

};


#endif // DOWNLOAD_H
