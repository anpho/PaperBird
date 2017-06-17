import bb.data 1.0
import bb.cascades 1.4
import bb.cascades.datamanager 1.2
import bb.system 1.2
Tab {
    function updateview() {
        // read history from database
    }
    signal request_open(string bookmarkurl)

    delegate: Delegate {
        Page {
            attachedObjects: [
                BookmarkEditDialog {
                    id: bed
                    onClosed: {
                        pageroot.reload();
                    }
                },
                SystemToast {
                    id: sst
                    position: SystemUiPosition.BottomCenter
                }
            ]
            titleBar: TitleBar {
                title: qsTr("Bookmark")
                acceptAction: ActionItem {
                    title: qsTr("CLEAR")
                    onTriggered: {
                        sd.exec()
                    }
                    attachedObjects: [
                        SystemDialog {
                            id: sd
                            title: qsTr("Confirm")
                            body: qsTr("This will clear all your bookmarks, confirm?")
                            includeRememberMe: false
                            customButton.enabled: false
                            onFinished: {
                                if (value == SystemUiResult.ConfirmButtonSelection) {
                                    _app.clearBookmarks();
                                    adm.load();
                                }
                            }
                        }
                    ]
                }
            }
            function reload() {
                adm.load();
            }
            id: pageroot
//            actionBarVisibility: ChromeVisibility.Hidden
            ListView {
                id: hlistview
                dataModel: AsyncDataModel {
                    id: adm
                    cacheSize: 200
                    query: SqlDataQuery {
                        id: sdq

                        source: "file://" + _app.getAbPath() + "/data/paperbird.db"
                        query: "SELECT bID,title, uri, timestamp from bookmarks order by timestamp desc"
                        countQuery: "select count(*) from bookmarks"
                        keyColumn: "bID"
                        onError: {
                            console.log(message)
                        }
                    }
                }
                onCreationCompleted: {
                    adm.load()
                }
                function requestdeletebyIDs(ids) {
                    _app.removeBookmarkBySet(ids);
                    adm.load()
                }
                function requestOpenInNewTab(u) {
                    request_open(u);
                }

                function requestEdit(bID, title, uri) {
                    bed.bid = bID;
                    bed.bname = title;
                    bed.buri = uri;
                    bed.open();
                }
                function requestHomepage(u) {
                    _app.setv("homepage", u)
                    sst.body = qsTr("Homepage Set");
                    sst.show();
                }
                listItemComponents: [
                    ListItemComponent {
                        StandardListItem {
                            id: itemroot
                            title: ListItemData.title
                            description: ListItemData.uri
                            contextActions: [
                                ActionSet {
                                    title: ListItemData.title
                                    actions: [
                                        DeleteActionItem {
                                            onTriggered: {
                                                itemroot.ListItem.view.requestdeletebyIDs(ListItemData.bID);
                                            }
                                        },
                                        ActionItem {
                                            title: qsTr("Open in New Tab")
                                            onTriggered: {
                                                itemroot.ListItem.view.requestOpenInNewTab(ListItemData.uri);
                                            }
                                            imageSource: "asset:///icon/ca_browser_blue.png"
                                        },
                                        ActionItem {
                                            title: qsTr("Edit")
                                            imageSource: "asset:///icon/ic_edit.png"
                                            onTriggered: {
                                                itemroot.ListItem.view.requestEdit(ListItemData.bID, ListItemData.title, ListItemData.uri)
                                            }
                                        },
                                        ActionItem {
                                            title: qsTr("Set Homepage")
                                            onTriggered: {
                                                itemroot.ListItem.view.requestHomepage(ListItemData.url);
                                            }
                                            imageSource: "asset:///icon/ic_homex.png"
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                ]
                onTriggered: {
                    var item = adm.data(indexPath);
                    request_open(item.uri);
                }
                multiSelectAction: MultiSelectActionItem {

                }
                multiSelectHandler {
                    actions: DeleteActionItem {
                        onTriggered: {
                            var selecteditems = hlistview.selectionList().sort()
                            var hids = [];
                            for (var i = selecteditems.length - 1; i > -1; i --) {
                                var indexpath = selecteditems[i];
                                var item = adm.data(indexpath);
                                hids.push(item.bID)
                            }
                            _app.removeBookmarkBySet(hids.join(","));
                            adm.load()
                        }
                    }
                    status: qsTr("None Selected.")
                    onActiveChanged: {
                        if (active == true) {
                            console.log("Multiple selection mode is enabled.")
                        } else {
                            console.log("Multiple selection mode is disabled.")
                        }
                    }
                }
                onSelectionChanged: {
                    if (selectionList().length > 1) {
                        multiSelectHandler.status = selectionList().length + qsTr(" items selected")
                    } else if (selectionList().length == 1) {
                        multiSelectHandler.status = qsTr("1 item selected");
                    } else {
                        multiSelectHandler.status = qsTr("None selected");
                    }
                }
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
            }

        }
    }
}
