import bb.cascades 1.4
import bb 1.0
Sheet {
    id: sheetroot
    property variant core
    Page {
        titleBar: TitleBar {
            title: qsTr("About")
            dismissAction: ActionItem {
                onTriggered: {
                    sheetroot.close()
                }
                title: qsTr("Close")
            }
        }
        ScrollView {
            horizontalAlignment: HorizontalAlignment.Fill
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: 40.0
                leftPadding: 20.0
                rightPadding: 20.0
                bottomPadding: 40.0

                ImageView {
                    imageSource: "asset:///images/icon3.png"
                    scalingMethod: ScalingMethod.AspectFit
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Top
                    preferredWidth: ui.du(15)
                    preferredHeight: ui.du(15)
                    topMargin: 50.0
                }
                Label {
                    text: qsTr("PaperBird is a native, lightweight web browser for BlackBerry 10")
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontWeight: FontWeight.W100
                    multiline: true
                }

                Container {
                    horizontalAlignment: HorizontalAlignment.Center
                    topPadding: 40.0
                    Label {
                        text: qsTr("Created by <a>Merrick Zhang</a>")
                        horizontalAlignment: HorizontalAlignment.Center
                        multiline: true
                        textStyle.fontWeight: FontWeight.W100
                        textFormat: TextFormat.Html
                        gestureHandlers: TapHandler {
                            onTapped: {
                                core.open_new_window("http://bbdev.cn")
                                sheetroot.close()
                            }
                        }
                    }
                    Label {
                        textFormat: TextFormat.Html
                        text: qsTr("<a href=\"appworld://vendor/26755\">My BlackBerry 10 Apps</a>")
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                }
                Header {
                    title: "UPDATE LOG"
                    topMargin: 50.0
                }
                Container {
                    id: updatelog_container
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: 20.0
                    leftPadding: 20.0
                    rightPadding: 20.0
                    bottomPadding: 20.0
                    Label {
                        text: qsTr("Loading (`へ´*)ノ")
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                }
            }
        }
        actions: [
            ActionItem {
                imageSource: "asset:///icon/ic_done.png"
                ActionBar.placement: ActionBarPlacement.Signature
                onTriggered: {
                    sheetroot.close()
                }
            }
        ]
        actionBarVisibility: ChromeVisibility.Compact
        attachedObjects: [
            Label {
                id: emptylabel
                multiline: true
                textFormat: TextFormat.Html
                textStyle.fontWeight: FontWeight.W100
                textStyle.textAlign: TextAlign.Left
                horizontalAlignment: HorizontalAlignment.Fill
            },
            Net {
                id: n
            }
        ]
        onCreationCompleted: {
            n.ajax("GET", "https://raw.githubusercontent.com/anpho/PaperBird/master/update.log", [], function(b, d) {
                    updatelog_container.removeAll()
                    emptylabel.text = d;
                    updatelog_container.add(emptylabel)
                }, [], false)
        }
    }

}