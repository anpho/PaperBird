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

#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <bb/data/SqlConnection>
#include <QtSql/QtSql>
#include <QDate>
#include <bb/cascades/InvokeQuery>
#include <bb/cascades/Invocation>
#include <bb/system/InvokeRequest>
#include <bb/system/InvokeManager>
namespace bb
{
    namespace cascades
    {
        class LocaleHandler;
    }
}
using namespace bb::data;
class QTranslator;

/*!
 * @brief Application UI object
 *
 * Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */
class ApplicationUI : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static void setv(const QString &objectName, const QString &inputValue);
    Q_INVOKABLE static QString getv(const QString &objectName, const QString &defaultValue);
    Q_INVOKABLE void appendHistory(const QString &title, const QString &uri);
    Q_INVOKABLE void updateHistoryByURI(const QString &title, const QString &uri);
    Q_INVOKABLE bool clearHistories();
    Q_INVOKABLE QString getAbPath();
    Q_INVOKABLE void deleteHistoryBySet(QString historyIDs);
    Q_INVOKABLE void shareText(QString text);
    Q_INVOKABLE void openWith(QString text);
    Q_INVOKABLE bool removeBookmarkBySet(const QString &ids);
    Q_INVOKABLE bool clearBookmarks();
    Q_INVOKABLE bool addBookmark(const QString &title, const QString &uri);
    Q_INVOKABLE bool updateBookmarkByID(const QString &bid, const QString &title, const QString &uri);
    Q_INVOKABLE QString getClipboard();
    ApplicationUI();
    ~ApplicationUI();
    Q_SLOT void onInvoke(const bb::system::InvokeRequest& invoke);
    Q_SIGNAL void open_a_new_tab_for_me(QString target);
private slots:
    void onSystemLanguageChanged();
    void onArmed();
    void onFinished();
    void onOPENArmed();
private:
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;
    // The connection to the SQL database
    bb::data::SqlConnection* m_sqlConnection;
    bool db_ready;
    bool initDatabase();
    bool initTables();
};

#endif /* ApplicationUI_HPP_ */
