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

#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/system/InvokeRequest>
#include <bb/system/InvokeManager>
#include <QLocale>
#include <QTranslator>

#include <Qt/qdeclarativedebug.h>
#include <unistd.h>
#include "WebImageView.h"

using namespace bb::cascades;
using namespace bb::system;
Q_DECL_EXPORT int main(int argc, char **argv)
{
    QSettings settings;
    if (!settings.value("theme").isNull()) {
        qputenv("CASCADES_THEME", settings.value("theme").toString().toUtf8());
    }
    qmlRegisterType<WebImageView>("cn.anpho", 1, 0, "WebImageView");
//    sleep(1);


    Application app(argc, argv);

    // Create the Application UI object, this is where the main.qml file
    // is loaded and the application scene is set.
    ApplicationUI appui;
    InvokeManager invokeManager;
    bool connectResult;
    Q_UNUSED(connectResult);
    connectResult = QObject::connect(&invokeManager,
            SIGNAL(invoked(const bb::system::InvokeRequest&)), &appui,
            SLOT(onInvoke(const bb::system::InvokeRequest&)));

    // This is only available in Debug builds
    Q_ASSERT(connectResult);

    switch(invokeManager.startupMode()) {
         case ApplicationStartupMode::LaunchApplication:
             // An app can initialize if it
             // was started from the home screen
             qDebug()<<"App started.";
             break;
         case ApplicationStartupMode::InvokeApplication:
             // If the app is invoked,
             // it must wait until it receives an invoked() signal
             // so that it can determine the UI that it needs to initialize
             qDebug()<<"App invoked.";
             break;
         default:
             // What app is it and how did it get here?
             break;
     }


    // Enter the application main event loop.
    return app.exec();
}
