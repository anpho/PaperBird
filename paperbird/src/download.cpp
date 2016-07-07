#include "download.h"

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QStringList>
#include <QFileInfo>
#include <QTimer>
#include <QUuid>
#include <QDir>
#include <QDebug>

Download::Download(QObject * parent) :
        QObject(parent), totalCount(0)
{
}

Download::~Download()
{
}

void Download::append(const QUrl & url)
{

    QString currentFileName = saveFileName(url);
    Queue queue;
    queue.key = getUuid();
    queue.url = url;

    // if already exists
    if (QFile::exists(currentFileName)) {
        qDebug() << "already exists";
        return;
    }

    // possibly has .part file
    QDir dir;
    QStringList filenames = dir.entryList();
    foreach(QString filename, filenames){
    if(filename.contains(".part") && filename.contains(currentFileName)) {
        QFile * part = new QFile(filename);
        queue.key = getUuid(filename);
        files.insert(queue.key, part);
        qDebug() << "resume" << queue.key;
        break;
    }
}

    if (downloadQueue.isEmpty())
        QTimer::singleShot(0, this, SLOT(startNextDownload()));

    downloadQueue.enqueue(queue);
}

void Download::startNextDownload()
{

    if (downloadQueue.isEmpty()) {
        return;
    }

    int length = downloadQueue.count() > 4 ? 4 : downloadQueue.count();

    for (int i = 0; i < length; i++) {

        Queue queue = downloadQueue.dequeue();

        QNetworkRequest request;

        if (files.contains(queue.key)) {
            // partial file resume download

            QFile * file = files.value(queue.key);
            if (!file->isOpen())
                file->open(QIODevice::ReadWrite);
            request.setRawHeader("Range", "bytes=" + file->size());

        } else {
            // new download
            QString filename = saveFileName(queue.url);
            QFile * output = new QFile(getPartFileName(filename, queue.key));

            if (!output->open(QIODevice::WriteOnly)) {
                output->deleteLater();
                startNextDownload();
                return;
            }
            files.insert(getUuid(output->fileName()), output);
        }

        request.setAttribute(QNetworkRequest::User, QVariant(queue.key));
        request.setUrl(queue.url);

        QNetworkReply * reply = manager.get(request);
        connect(reply, SIGNAL(downloadProgress(qint64,qint64)),
                SLOT(downloadProgress(qint64,qint64)));
        connect(reply, SIGNAL(finished()), SLOT(downloadFinished()));
        connect(reply, SIGNAL(readyRead()), SLOT(downloadReadyRead()));

    }
}

void Download::downloadProgress(qint64 bytes, qint64 bytesTotal)
{
    QNetworkReply * reply = qobject_cast<QNetworkReply *>(sender());
    qDebug() << reply->request().url().toString() << " " << bytes;
}

void Download::downloadReadyRead()
{
    QNetworkReply * reply = qobject_cast<QNetworkReply *>(sender());
    QString key = reply->request().attribute(QNetworkRequest::User).toString();
    QFile * output = files.value(key);
    output->write(reply->readAll());
}

void Download::downloadFinished()
{
    QNetworkReply * reply = qobject_cast<QNetworkReply *>(sender());
    QString key = reply->request().attribute(QNetworkRequest::User).toString();
    QFile * output = files.value(key);
    output->rename(getOriginalFilename(output->fileName(), key));
    output->close();
    output->deleteLater();
}

QString Download::getUuid(const QString & str)
{
    if (str.isEmpty())
        return QUuid::createUuid();

    int start = str.indexOf("-{") + 1;
    int end = str.indexOf(".part");
    return str.mid(start, end - start);
}

void Download::append(const QStringList & urlList)
{
    foreach (QString url, urlList){
    append(QUrl::fromEncoded(url.toLocal8Bit()));
}
}

QString Download::saveFileName(const QUrl & url)
{
    //TODO Download Path
    QString path = url.path();
    QString basename = QFileInfo(path).fileName();

    if (basename.isEmpty())
        basename = QUuid::createUuid();

    return basename;
}

QString Download::getPartFileName(const QString & filename, const QString & key)
{
    return filename + "-" + (key.isEmpty() ? getUuid() : key) + ".part";
}

QString Download::getOriginalFilename(const QString & filename, const QString & key)
{
    return filename.left(filename.lastIndexOf("-" + key + ".part"));
}

