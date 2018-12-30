/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "qobject.h"
#include "applicationui.hpp"
#include <bb/system/Clipboard>
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <qdir.h>
using namespace Qt;
using namespace bb::cascades;
ApplicationUI::~ApplicationUI()
{
    QSqlDatabase database = QSqlDatabase::database();
    if (database.isOpen()) {
        database.close();
    }
}
ApplicationUI::ApplicationUI() :
        QObject()
{

    // prepare the localization
    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);

    bool res = QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this,
            SLOT(onSystemLanguageChanged()));
    // This is only available in Debug builds
    Q_ASSERT(res);
    // Since the variable is not used in the app, this is added to avoid a
    // compiler warning
    Q_UNUSED(res);

    // initial load
    onSystemLanguageChanged();

    // init database for history and bookmarks usage.
    initDatabase();

    // Create scene document from main.qml asset, the parent is set
    // to ensure the document gets destroyed properly at shut down.
    QmlDocument *qml = QmlDocument::create("qrc:/assets/main.qml").parent(this);
    qml->setContextProperty("_app", this);

    // Create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();

    // Set created root object as the application scene
    Application::instance()->setScene(root);
}
QString ApplicationUI::getAbPath()
{
    return QDir().absolutePath();
}
void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    // Initiate, load and install the application translation files.
    QString locale_string = QLocale().name();
    QString file_name = QString("paperbird_%1").arg(locale_string);
    if (m_pTranslator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}

QString ApplicationUI::getv(const QString &objectName, const QString &defaultValue)
{
    // This method returns a config value, if invalid, return 2nd param.
    QSettings settings;
    if (settings.value(objectName).isNull()) {
        return defaultValue;
    }
    qDebug() << "[SETTINGS]" << objectName << " is " << settings.value(objectName).toString();
    return settings.value(objectName).toString();
}

void ApplicationUI::setv(const QString &objectName, const QString &inputValue)
{
    // This method create / set a config key/value pair.
    QSettings settings;
    settings.setValue(objectName, QVariant(inputValue));
    qDebug() << "[SETTINGS]" << objectName << " set to " << inputValue;
}

bool ApplicationUI::initDatabase()
{
    /*
     * this function is used to create the database file
     */
    QSqlDatabase database = QSqlDatabase::addDatabase("QSQLITE");
    bool success = false;

    // 2. Set the path of where the database will be located.
    //    Note: The db extension is not required
    database.setDatabaseName("./data/paperbird.db");

    // 3. Open a connection to the database, if the database does not exist
    //    one will be created if permitted.
    if (database.open()) {
        success = true;
        initTables();

    } else {
        const QSqlError error = database.lastError();
        qDebug() << QString("Error opening connection to the database: %1").arg(error.text());
    }
    return success;
}
bool ApplicationUI::initTables()
{
    /*
     * create tables for history & bookmark feature
     */
    QSqlDatabase database = QSqlDatabase::database();
    bool success = false;
    const QString createSQL = "CREATE TABLE IF NOT EXISTS histories ( "
            "                historyID INTEGER PRIMARY KEY AUTOINCREMENT, "
            "                title VARCHAR, "
            "                domain VARCHAR,"
            "                uri VARCHAR,"
            "               timestamp VARCHAR"
            ");";
    QSqlQuery query(database);
    if (query.exec(createSQL)) {
        success = true;
        qDebug() << "[DB]History table created.";
    } else {
        const QSqlError error = query.lastError();
        qDebug() << tr("Create table error: %1").arg(error.text());
    }
    const QString createFavSQL = "CREATE TABLE IF NOT EXISTS bookmarks ( "
            "                bID INTEGER PRIMARY KEY AUTOINCREMENT, "
            "                title VARCHAR, "
            "                sub VARCHAR,"
            "                uri VARCHAR,"
            "               timestamp VARCHAR"
            ");";
    if (query.exec(createFavSQL)) {
        success = true;
        qDebug() << "[DB]Fav table created.";
    } else {
        success = false;
        const QSqlError error = query.lastError();
        qDebug() << tr("Create table error: %1").arg(error.text());
    }
    return success;
}

/*
 * INVOKATION FEATURES
 */

void ApplicationUI::shareText(QString text)
{
    /*
     * invoke text sharing
     */
    InvokeQuery *query = InvokeQuery::create().data(text.toUtf8()).mimeType("text/plain");
    Invocation *invocation = Invocation::create(query);
    query->setParent(invocation); // destroy query with invocation
    invocation->setParent(this); // app can be destroyed before onFinished() is called
    connect(invocation, SIGNAL(armed()), this, SLOT(onArmed()));
    connect(invocation, SIGNAL(finished()), this, SLOT(onFinished()));
}
void ApplicationUI::onArmed()
{
    /*
     * when invoked, do share
     */
    Invocation *invocation = qobject_cast<Invocation *>(sender());
    invocation->trigger("bb.action.SHARE");
}
void ApplicationUI::onFinished()
{
    /*
     * release memory
     */
    Invocation *invocation = qobject_cast<Invocation *>(sender());
    invocation->deleteLater();
}

void ApplicationUI::openWith(QString text)
{
    /*
     * open url with ..?
     * this function is used to invoke a list for user to choose which application to use.
     */
    InvokeQuery *query = InvokeQuery::create().uri(text.toUtf8());
    Invocation *invocation = Invocation::create(query);
    query->setParent(invocation); // destroy query with invocation
    invocation->setParent(this); // app can be destroyed before onFinished() is called
    connect(invocation, SIGNAL(armed()), this, SLOT(onOPENArmed()));
    connect(invocation, SIGNAL(finished()), this, SLOT(onFinished()));

}
void ApplicationUI::onOPENArmed()
{
    /*
     * open
     */
    Invocation *invocation = qobject_cast<Invocation *>(sender());
    invocation->trigger("bb.action.OPEN");
}

/*
 * HISTORY FEATURE
 */

void ApplicationUI::deleteHistoryBySet(QString historyIDs)
{
    QSqlDatabase database = QSqlDatabase::database();
    const QString deleteSQL = "DELETE FROM histories WHERE historyID IN ( " + historyIDs + ")";
    QSqlQuery query(database);
    if (query.exec(deleteSQL)) {
        qDebug() << "[DB]History table cleared.";
    } else {
        const QSqlError error = query.lastError();
        qDebug() << tr("Delete table error: %1").arg(error.text());
    }
}
void ApplicationUI::appendHistory(const QString &title, const QString &uri)
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.tables().contains("histories")) {
        // If there's no history table, create it.
        qDebug() << "[DB]Histories table doesn't exists, creating... ";
        initTables();
    }
    // get the domain information
    QUrl ur = QUrl(uri);
    QString domain = ur.host();
    qDebug() << "[DB] Appending History at domain : " << domain;

    // get the timestamp
    QString timestamp = QDateTime().currentDateTime().toString(Qt::ISODate);
    qDebug() << "[DB]Timestamp is :" << timestamp;

    // create the sql
    QSqlQuery query(database);
    query.prepare(
            "INSERT INTO histories (title, domain, uri, timestamp) VALUES(:title, :domain, :uri, :timestamp)");
    query.bindValue(":title", title);
    query.bindValue(":domain", domain);
    query.bindValue(":uri", uri);
    query.bindValue(":timestamp", timestamp);

    // Note that no SQL Statement is passed to 'exec' as it is a prepared statement.
    if (query.exec()) {
        qDebug() << "[DB]entry created.";
    } else {
        const QSqlError error = query.lastError();
        qDebug() << QString("Create record error: %1").arg(error.text());
    }
}
void ApplicationUI::updateHistoryByURI(const QString &title, const QString &uri)
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.tables().contains("histories") || !database.tables().contains("bookmarks")) {
        // if there's no history table create it.
        qDebug() << "[DB]Database structure not ready, creating tables... ";
        initTables();
    }
    // get the domain information
    QUrl ur = QUrl(uri);
    QString domain = ur.host();
    qDebug() << "[DB] Updating History at domain : " << domain;

    // get the timestamp
    QString timestamp = QDateTime().currentDateTime().toString(Qt::ISODate);
    qDebug() << "[DB] Timestamp is :" << timestamp;

    // create the sql
    QSqlQuery query(database);
    query.prepare("UPDATE histories set title=:title, timestamp= :timestamp where uri= :uri");
    query.bindValue(":title", title);
    query.bindValue(":uri", uri);
    query.bindValue(":timestamp", timestamp);

    // Note that no SQL Statement is passed to 'exec' as it is a prepared statement.
    if (query.exec()) {
        if (query.numRowsAffected() == 0) {
            appendHistory(title, uri);
        }
        qDebug() << "[DB]entry updated.";
    } else {
        const QSqlError error = query.lastError();
        qDebug() << QString("Update record error: %1").arg(error.text());
    }
}
bool ApplicationUI::clearHistories()
{
    /*
     * Erease all entries in histories table, used to clear the history.
     */
    QSqlDatabase database = QSqlDatabase::database();
    bool success = false;
    const QString deleteSQL = "DELETE FROM histories";
    QSqlQuery query(database);
    if (query.exec(deleteSQL)) {
        success = true;
        qDebug() << "[DB]History table cleared.";
    } else {
        const QSqlError error = query.lastError();
        qDebug() << tr("Delete table error: %1").arg(error.text());
    }
    return success;
}
/*
 * BOOKMARK FEATURE
 */

QString ApplicationUI::getClipboard()
{
    bb::system::Clipboard clipboard;
    QByteArray data = clipboard.value("text/plain");
    if (!data.isEmpty()) {
        QString content = QString::fromUtf8(data, data.size());
        return content;
    } else {
        return "";
    }
}
bool ApplicationUI::clearSettings(){
    QSettings settings;
    settings.clear();
}
bool ApplicationUI::clearBookmarks()
{
    /*
     * Erease all entries in bookmarks table, used to clear the bookmarks.
     */
    QSqlDatabase database = QSqlDatabase::database();
    bool success = false;
    const QString deleteSQL = "DELETE FROM bookmarks";
    QSqlQuery query(database);
    if (query.exec(deleteSQL)) {
        success = true;
        qDebug() << "[DB]Bookmark table cleared.";
    } else {
        const QSqlError error = query.lastError();
        qDebug() << tr("Delete table error: %1").arg(error.text());
    }
    return success;
}

bool ApplicationUI::addBookmark(const QString &title, const QString &uri)
{
    bool success = false;
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.tables().contains("bookmarks")) {
        // if there's no bookmarks table, create it
        qDebug() << "[DB]Bookmarks table doesn't exists, creating... ";
        initTables();
    }

    // get the timestamp
    QString timestamp = QDateTime().currentDateTime().toString(Qt::ISODate);
    qDebug() << "[DB]Timestamp is :" << timestamp;

    // create the sql
    QSqlQuery query(database);
    query.prepare("INSERT INTO bookmarks (title, uri, timestamp) VALUES(:title, :uri, :timestamp)");
    query.bindValue(":title", title);
    query.bindValue(":uri", uri);
    query.bindValue(":timestamp", timestamp);

    // Note that no SQL Statement is passed to 'exec' as it is a prepared statement.
    if (query.exec()) {
        success = true;
        qDebug() << "[DB]bookmark entry created.";
    } else {
        const QSqlError error = query.lastError();
        qDebug() << QString("Create record error: %1").arg(error.text());
    }
    return success;
}

bool ApplicationUI::removeBookmarkBySet(const QString &ids)
{
    bool success = false;
    QSqlDatabase database = QSqlDatabase::database();
    const QString deleteSQL = "DELETE FROM bookmarks WHERE bID IN ( " + ids + ")";
    QSqlQuery query(database);
    if (query.exec(deleteSQL)) {
        success = true;
        qDebug() << "[DB]bookmark deleted :" << ids;
    } else {
        const QSqlError error = query.lastError();
        qDebug() << tr("Delete bookmark error: %1").arg(error.text());
    }
    return success;
}

bool ApplicationUI::updateBookmarkByID(const QString &bid, const QString &title, const QString &uri)
{
    bool success = false;
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.tables().contains("bookmarks")) {
        // if there's no bookmarks table, create it
        qDebug() << "[DB]Database structure not ready, creating tables... ";
        initTables();
    }

    // get the timestamp
    QString timestamp = QDateTime().currentDateTime().toString(Qt::ISODate);
    qDebug() << "[DB] Timestamp is :" << timestamp;

    // create the sql
    QSqlQuery query(database);
    query.prepare(
            "UPDATE bookmarks set title=:title, uri=:uri, timestamp= :timestamp where bID= :bid");
    query.bindValue(":title", title);
    query.bindValue(":uri", uri);
    query.bindValue(":bid", bid);
    query.bindValue(":timestamp", timestamp);

    // Note that no SQL Statement is passed to 'exec' as it is a prepared statement.
    if (query.exec()) {
        if (query.numRowsAffected() != 0) {
            success = true;
        }
        qDebug() << "[DB]entry updated.";
    } else {

        const QSqlError error = query.lastError();
        qDebug() << QString("Update record error: %1").arg(error.text());
    }
    return success;
}

void ApplicationUI::onInvoke(const bb::system::InvokeRequest& invoke)
{
    // this is the receiver when app is invoked via other apps,
    // for example, when in system browser and select "open with / paperbird"

    QString target_url = invoke.uri().toString();
    if (target_url.length() > 0) {
        if (target_url.startsWith("anpho:")) {
            target_url.remove(0, 6);
        }
        qDebug() << "using target url : " << target_url;
        emit open_a_new_tab_for_me(target_url);
    } else {
        target_url = QString(invoke.data());
        qDebug() << "using data : " << target_url;
        emit open_a_new_tab_for_me(target_url);
    }

}
