import bb.data 1.0
import bb.cascades 1.4
import bb.cascades.datamanager 1.2
import bb.system 1.2
Tab {
    function updateview() {
    }
    signal request_open(string bookmarkurl)

    delegate: Delegate {
        Page {
            actionBarVisibility: ChromeVisibility.Compact
            attachedObjects: [
                SystemToast {
                    id: sst
                    position: SystemUiPosition.BottomCenter
                }
            ]
            titleBar: TitleBar {
                title: qsTr("PaperBird Browser")
                visibility: ChromeVisibility.Visible
            }
            id: pageroot
            //            actionBarVisibility: ChromeVisibility.Hidden
            Container {
                layout: DockLayout {

                }
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: 50.0
                leftPadding: 20.0
                rightPadding: 20.0
                bottomPadding: 50.0

                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center

                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight

                    }

                    Button {
                        imageSource: "asset:///icon/ic_scan_barcode.png"
                        appearance: ControlAppearance.Default
                        preferredWidth: 1.0
                        
                    }
                    Button {
                        preferredWidth: 1.0
                        imageSource: "asset:///icon/ic_paste.png"
                        onClicked: {
                            address_text_input.setText(_app.getClipboard());
                        }
                    }
                    TextField {
                        id: address_text_input
                        hintText: qsTr("Type URL here")
                        textFormat: TextFormat.Plain
                        inputMode: TextFieldInputMode.Url
                        autoFit: TextAutoFit.None
                        input.submitKey: SubmitKey.Go
                        input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                        input.keyLayout: KeyLayout.Url
                        implicitLayoutAnimationsEnabled: false
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }
                        input.onSubmitted: {
                            if (text.length > 0) {
                                request_open(text);
                            }
                        }
                        onFocusedChanged: {
                            if (focused) {
                                editor.setSelection(0, text.length);
                            } else {
                            }
                        }
                    }
                    Button {
                        appearance: ControlAppearance.Primary
                        imageSource: "asset:///icon/ic_go_to.png"
                        preferredWidth: 1.0
                        enabled: address_text_input.text.length>0
                        onClicked: {
                            request_open(address_text_input.text);
                            }

                    }
                }
            }
        }
    }
}
