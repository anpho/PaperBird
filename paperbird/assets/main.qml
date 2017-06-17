import bb.cascades 1.4
import bb.system 1.2

TabbedPane {
    id: root
    function open_new_tab(target) {
        webnest.open_new_window(target)
    }
    onCreationCompleted: {
        _app.open_a_new_tab_for_me.connect(open_new_tab);
        Application.aboutToQuit.connect(app_exit_slot);
        var startupmode = parseInt(_app.getv("startup", "2"));
        switch (startupmode) {
            case 0:
                break;
            case 1:
                open_new_tab(_app.getv("homepage", null))
                break;
            case 2:
                open_new_tab();
                break;
            default:
                break;
        }
    }
    function app_exit_slot() {
        var _clear_cache = _app.getv("clearcache", "false") === "true";
        if (_clear_cache) {
            // clear cache
            useless_webview.storage.clearCache()
            console.log("cache cleared.");
        }
        var _clear_history = _app.getv("clearhistory", "false") === "true";
        if (_clear_history) {
            // clear history
            _app.clearHistories();
            console.log("history cleared.")
        }
    }

    Tab_Bookmark {
        id: tab_bookmark
        title: qsTr("Bookmark")
        imageSource: "asset:///icon/ic_bookmarks.png"
        onRequest_open: {
            console.log("REQUEST OPEN: " + bookmarkurl)
            webnest.open_new_window(bookmarkurl)
        }
    }
    Tab_History {
        id: tab_history
        title: qsTr("History")
        imageSource: "asset:///icon/ic_history.png"
        onRequest_open: {
            console.log("REQUEST OPEN: " + historyurl)
            webnest.open_new_window(historyurl)
        }
    }
    Tab {
        id: add_new_window
        title: qsTr("New Window")
        imageSource: "asset:///icon/ic_add.png"
        onTriggered: {
            webnest.open_new_window()
        }
    }
    onTabRemoved: {
        sst.body = (qsTr('"%1" Closed').arg(tab.title))
        //close_sst.current_url = tab.description;
        sst.show();
        //description
    }
    function showToast(str) {
        sst.body = str;
        sst.show();
    }
    attachedObjects: [
        CoreObject {
            id: webnest
            tabhost: root
            tabtemplate: tabcomponent
            //            tabhistory: tab_history
        },
        ComponentDefinition {
            id: tabcomponent
            source: "Tab_PageTemplate.qml"
        },
        SystemToast {
            id: sst
            position: SystemUiPosition.BottomCenter
        },
        SystemToast {
            id: close_sst
            property string current_url
            position: SystemUiPosition.BottomCenter
            button.label: qsTr("Undo")
            onFinished: {
                console.log(value)
                if (value == SystemUiResult.ButtonSelection) {
                    open_new_tab(current_url)
                }
            }
        },
        WebView {
            id: useless_webview
        }
    ]
    showTabsOnActionBar: false
    sidebarState: SidebarState.VisibleCompact
    onActiveTabChanged: {
    }
    activeTab: tab_bookmark
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            onTriggered: {
                var absheet = Qt.createComponent("Sheet_About.qml").createObject(root);
                absheet.core = webnest;
                absheet.open();
            }
        }
        settingsAction: SettingsActionItem {
            onTriggered: {
                var absheet = Qt.createComponent("Sheet_Settings.qml").createObject(root);
                absheet.core = webnest;
                absheet.open();
            }
        }
        actions: [
            ActionItem {
                title: qsTr("Review")
                imageSource: "asset:///icon/ic_favorite.png"
                onTriggered: {
                    Qt.openUrlExternally("appworld://content/59954004")
                }
            },
            ActionItem {
                title: qsTr("Feedback")
                imageSource: "asset:///icon/ic_feedback.png"
                onTriggered: {
                    open_new_tab("https://github.com/anpho/PaperBird/issues")
                }
            }
        ]
    }
    objectName: "mainroot"
}
