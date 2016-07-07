import bb.cascades 1.4
import bb.system 1.2
Dialog {

    id: dialogroot
    property string bid
    property string bname
    property string buri
    Container {
        verticalAlignment: VerticalAlignment.Fill
        horizontalAlignment: HorizontalAlignment.Fill
        layout: DockLayout {

        }
        background: Color.create("#bb000000")
        leftPadding: 40.0
        rightPadding: 40.0
        locallyFocused: true
        Container {
            topPadding: 20.0
            leftPadding: 20.0
            rightPadding: 20.0
            bottomPadding: 20.0
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            background: ui.palette.background
            Header {
                title: qsTr("Edit Bookmark")
            }
            Label {
                text: qsTr("Bookmark Name:")

            }
            TextField {
                id: bookmark_name
                hintText: qsTr("Bookmark Name")
                text: bname

            }
            Label {
                text: qsTr("Address:")
            }
            TextField {
                id: bookmark_uri
                hintText: qsTr("Bookmark URI")
                text: buri

            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight

                }
                Button {
                    text: qsTr("Cancel")
                    onClicked: {
                        dialogroot.close();
                    }
                }
                Button {
                    text: qsTr("Done")
                    onClicked: {
                        if ((bookmark_name.text == bname) && (bookmark_uri.text.toLowerCase() == buri.toLowerCase())) {
                            console.log("errrrrrrr")
                            dialogroot.close();
                            return;
                        }
                        console.log("ohhhhhh")
                        if (bookmark_name.text.length > 0 && bookmark_uri.text.indexOf(":") > -1) {
                            var result = _app.updateBookmarkByID(bid, bookmark_name.text, bookmark_uri.text)
                            if (result) {
                                dialogroot.close();
                            } else {
                                sst.show();
                            }
                        } else {
                            sst.show();
                        }
                    }
                }
            }
        }
    }
    attachedObjects: [
        SystemToast {
            id: sst
            body: qsTr("Something is wrong, please check your input.")
            position: SystemUiPosition.BottomCenter
        }
    ]
}
