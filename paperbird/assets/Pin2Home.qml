import bb.cascades 1.4
import bb.platform 1.0
import bb.cascades.pickers 1.0
import bb.system 1.0
Sheet {
    id: sheetroot
    property string defaultIcon: "asset:///icon/ca_browser_blue.png"
    property string icon: defaultIcon
    property string title
    property string url

    attachedObjects: [
        HomeScreen {
            id: homescreenobj
        },
        FilePicker {
            id: iconPicker
            title: "Choose an Icon"
            type: FileType.Picture
            defaultType: FileType.Picture
            sourceRestriction: FilePickerSourceRestriction.LocalOnly
            viewMode: FilePickerViewMode.Default
            sortBy: FilePickerSortFlag.Name
            sortOrder: FilePickerSortOrder.Ascending
            onCanceled: {
                icon = defaultIcon;
            }
            onFileSelected: {
                if (selectedFiles.length > 0) {
                    icon = "file://" + selectedFiles[0];
                } else {
                    icon = defaultIcon;
                }
            }
            imageCropEnabled: true
        },
        SystemToast {
            id: sstt
            position: SystemUiPosition.BottomCenter
        }

    ]
    Page {
        titleBar: TitleBar {
            title: qsTr("Pin to HomeScreen")
            dismissAction: ActionItem {
                title: qsTr("Cancel")
                onTriggered: {
                    sheetroot.close()
                }
            }
        }

        Container {

            Container {
                leftMargin: 20.0
                rightMargin: 20.0
                leftPadding: 20.0
                rightPadding: 20.0
                topMargin: 20.0
                bottomMargin: 20.0
                topPadding: 20.0
                bottomPadding: 20.0
                Label {
                    text: qsTr("Icon:")
                }
                ImageButton {
                    defaultImageSource: icon
                    pressedImageSource: icon
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    preferredWidth: 128.0
                    preferredHeight: 128.0
                    topMargin: 30.0
                    onClicked: {
                        iconPicker.open()
                    }
                }
                Label {
                    text: qsTr("Title:")
                }
                TextField {
                    id: text_title
                    hintText: qsTr("Shortcut Title")
                    text: title
                    textFormat: TextFormat.Plain
                    inputMode: TextFieldInputMode.Text
                    autoFit: TextAutoFit.None
                    input.submitKey: SubmitKey.Go
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    input.keyLayout: KeyLayout.Text
                    textStyle.textAlign: TextAlign.Center
                    validator: Validator {
                        mode: ValidationMode.Immediate
                        onValidate: {
                            if (text_title.text.trim().length == 0 || text_title.text.indexOf("\\") > -1) {
                                state = ValidationState.Invalid
                                valid = false
                            } else {
                                state = ValidationState.Valid
                                valid = true
                            }
                        }
                        errorMessage: qsTr("Shouldn't be Empty or with \\ .")
                        validationRequested: true
                    }

                }
                Label {
                    text: qsTr("URL:")
                }
                TextField {
                    text: url
                    id: text_url
                    hintText: qsTr("Web page URL")
                    textFormat: TextFormat.Plain
                    inputMode: TextFieldInputMode.Url
                    autoFit: TextAutoFit.None
                    input.submitKey: SubmitKey.Go
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    input.keyLayout: KeyLayout.Url
                    textStyle.textAlign: TextAlign.Center
                    validator: Validator {
                        mode: ValidationMode.Immediate
                        onValidate: {
                            if (text_url.text.trim().length == 0 || text_url.text.indexOf("://") < 0) {
                                state = ValidationState.Invalid
                                valid = false
                            } else {
                                state = ValidationState.Valid
                                valid = true
                            }
                        }
                        validationRequested: true
                        errorMessage: qsTr("Should be start with http:// or https://")
                    }
                }
            }
        }
        actions: [
            ActionItem {
                imageSource: "asset:///icon/ic_done.png"
                ActionBar.placement: ActionBarPlacement.Signature
                title: qsTr("Done")
                onTriggered: {
                    if (text_title.validator.valid && text_url.validator.valid) {
                        console.log("Add shortcut to homescreen, %1, %2, %3", icon, title, url);
                        homescreenobj.addShortcut(icon, text_title.text, "anpho:" + text_url.text);
                        sstt.body = qsTr("Shortcut Created");
                        sstt.show();
                        sheetroot.close()
                    }
                    console.log("Wrong, %1, %2, %3", icon, text_title.text, "anpho:" + text_url.text);
                }
            }
        ]
        actionBarVisibility: ChromeVisibility.Compact
    }
}