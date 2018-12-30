import bb.cascades 1.4
import bb.system 1.2
import bb.cascades.pickers 1.0
Sheet {
    id: sheetroot
    property variant core

    /*
     * Refer main.cpp to see how to apply this on app boot up.
     */
    property string themestring: "%1?primaryColor=0x%2&amp;primaryBase=0x%3"
    function savetheme() {
        var primarycolor = Color.toHexString(Application.themeSupport.theme.colorTheme.primary).substring(3, 9)
        var primarybase = Color.toHexString(Application.themeSupport.theme.colorTheme.primaryBase).substring(3, 9)
        var style = Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "dark" : "bright"
        var theme = themestring.arg(style).arg(primarycolor).arg(primarybase)
        _app.setv("theme", theme)
    }
    Page {
        onCreationCompleted: {
            /*
             * it needs some time for themeSupport to apply, so just connect to the signal in order to save the latest color schemes.
             * here I dismissed the argument of this signal ( not registered in Cascades )
             */
            Application.themeSupport.themeChanged.connect(savetheme)
        }
        attachedObjects: [
            SystemToast {
                id: sst
                position: SystemUiPosition.BottomCenter

            },
            WebView {
                id: configwebview
            }
        ]
        titleBar: TitleBar {
            title: qsTr("SETTINGS")
            dismissAction: ActionItem {
                title: qsTr("CLOSE")
                onTriggered: {
                    sheetroot.close()
                }
            }
        }
        ScrollView {
            Container {
                Header {
                    title: qsTr("UI SETTINGS")
                }
                Container {
                    topPadding: 20.0
                    leftPadding: 20.0
                    rightPadding: 20.0
                    bottomPadding: 20.0
                    Label {
                        text: qsTr("Visual Theme")
                        bottomMargin: 20.0
                        textStyle.fontWeight: FontWeight.W400
                        textStyle.fontSize: FontSize.Large
                    }
                    Label {
                        text: qsTr("Choose your theme below, Dark theme is better for OLED devices.")
                        multiline: true
                        textStyle.fontWeight: FontWeight.W100
                    }
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }

                        Label {
                            text: qsTr("App Theme:")
                            implicitLayoutAnimationsEnabled: false
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1.0
                            }
                            verticalAlignment: VerticalAlignment.Center
                        }
                        SegmentedControl {
                            options: [
                                Option {
                                    text: qsTr("BRIGHT")
                                    value: VisualStyle.Bright
                                    selected: VisualStyle.Bright == Application.themeSupport.theme.colorTheme.style
                                    description: "bright"

                                },
                                Option {
                                    text: qsTr("DARK")
                                    value: VisualStyle.Dark
                                    selected: VisualStyle.Dark == Application.themeSupport.theme.colorTheme.style
                                    description: "dark"
                                }
                            ]
                            onSelectedOptionChanged: {
                                Application.themeSupport.setVisualStyle(selectedOption.value)
                            }
                            verticalAlignment: VerticalAlignment.Center
                            horizontalAlignment: HorizontalAlignment.Right
                            implicitLayoutAnimationsEnabled: false
                            preferredWidth: 1.0
                        }

                    }

                }
                Container {
                    topPadding: 20.0
                    leftPadding: 20
                    rightPadding: 20
                    bottomPadding: 20.0
                    Label {
                        text: qsTr("Theme Color:")
                    }
                    ListView {
                        preferredHeight: ui.du(12)
                        dataModel: XmlDataModel {
                            id: xdm
                            source: "asset:///colors.xml"
                        }
                        leftPadding: 20.0
                        rightPadding: 20.0
                        topPadding: 20.0
                        bottomPadding: 20.0
                        layout: StackListLayout {
                            orientation: LayoutOrientation.LeftToRight
                            headerMode: ListHeaderMode.None

                        }
                        listItemComponents: [
                            ListItemComponent {
                                type: "item"
                                Container {
                                    preferredHeight: ui.du(12)
                                    preferredWidth: ui.du(12)
                                    background: Color.create(ListItemData.color)
                                    topMargin: ui.du(1.0)
                                    leftMargin: ui.du(1.0)
                                    rightMargin: ui.du(1.0)
                                    bottomMargin: ui.du(1.0)
                                }
                            }
                        ]
                        onTriggered: {
                            var _color = xdm.data(indexPath).color
                            Application.themeSupport.setPrimaryColor(Color.create(_color))
                            Application.themeSupport.setPrimaryColor(Color.create(_color))
                        }
                        implicitLayoutAnimationsEnabled: false
                        scrollIndicatorMode: ScrollIndicatorMode.ProportionalBar
                        bufferedScrollingEnabled: true
                    }
                }

                Header {
                    title: qsTr("BROWSER SETTINGS")
                }
                Container {
                    topPadding: 20.0
                    leftPadding: 20
                    rightPadding: 20
                    bottomPadding: 20.0
                    Label {
                        text: qsTr("Homepage")
                        bottomMargin: 20.0
                        textStyle.fontWeight: FontWeight.W400
                        textStyle.fontSize: FontSize.Large
                    }
                    Label {
                        text: qsTr("You can set the homepage URL here, or through other places' context menu.")
                        multiline: true
                        textStyle.fontWeight: FontWeight.W100
                    }
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight

                        }
                        TextField {
                            text: _app.getv("homepage", "")
                            hintText: qsTr("Set homepage URL here")
                            textFormat: TextFormat.Plain
                            inputMode: TextFieldInputMode.Url
                            input.submitKey: SubmitKey.Submit
                            input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                            input.keyLayout: KeyLayout.Url
                            input.onSubmitted: {
                                _app.setv("homepage", text);
                                sst.body = qsTr("Homepage Set")
                                sst.show()
                            }
                            id: homepage_text_input
                        }
                        Button {

                            preferredWidth: 1.0
                            appearance: ControlAppearance.Primary
                            onClicked: {
                                _app.setv("homepage", homepage_text_input.text);
                                sst.body = qsTr("Homepage Set")
                                sst.show()
                            }
                            imageSource: "asset:///icon/ic_done.png"
                        }
                    }
                    Divider {

                    }
                    Label {
                        text: qsTr("Search Engine")
                        textStyle.fontWeight: FontWeight.W400
                        textStyle.fontSize: FontSize.Large
                    }
                    Label {
                        text: qsTr("When you type something in address bar and hit GO, the selected search engine is used to search for it.")
                        multiline: true
                        textStyle.fontWeight: FontWeight.W100
                    }
                    DropDown {
                        selectedIndex: parseInt(_app.getv("se", "0"))
                        options: [
                            Option {
                                text: qsTr("Bing")
                                value: "http://bing.com/search?q=%1"
                            },
                            Option {
                                text: qsTr("Google")
                                value: "https://www.google.com/search?q=%1"
                            },
                            Option {
                                text: qsTr("Baidu")
                                value: "http://www.baidu.com/s?ie=utf-8&wd=%1"
                            },
                            Option {
                                text: qsTr("Yahoo")
                                value: "http://search.yahoo.com/search?p=%1&ei=UTF-8"
                            },
                            Option {
                                text: qsTr("Twitter")
                                value: "https://twitter.com/search?q=%1"
                            },
                            Option {
                                text: qsTr("Taobao")
                                value: "http://s.m.taobao.com/h5?q=%1"
                            }
                        ]
                        onSelectedIndexChanged: {
                            _app.setv("se", selectedIndex);
                        }
                        onSelectedValueChanged: {
                            _app.setv("searchurl", selectedValue)
                        }
                        title: qsTr("Selected Search Engine:")
                    }
                    Divider {

                    }
                    Label {
                        text: qsTr("User Agent")
                        textStyle.fontWeight: FontWeight.W400
                        textStyle.fontSize: FontSize.Large
                    }
                    Label {
                        text: qsTr("User-Agent(UA) is used by web sites to identify the type of device you're using, please use NEXUS for better compatibility.")
                        multiline: true
                        textStyle.fontWeight: FontWeight.W100
                    }
                    DropDown {
                        selectedIndex: parseInt(_app.getv("useragentid", "0"))
                        options: [
                            Option {
                                text: qsTr("NEXUS")
                                value: "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.83 Mobile Safari/537.36 PaperBird"
                            },
                            Option {
                                text: qsTr("iPhone 4")
                                value: "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"
                            },
                            Option {
                                text: qsTr("Opera Desktop")
                                value: "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.52 Safari/537.36 OPR/15.0.1147.100"
                            },
                            Option {
                                text: qsTr("Opera 12 Mobile")
                                value: "Opera/12.02 (Android 4.1; Linux; Opera Mobi/ADR-1111101157; U; en-US) Presto/2.9.201 Version/12.02"
                            },
                            Option {
                                text: qsTr("BlackBerry 9900")
                                value: "Mozilla/5.0 (BlackBerry; U; BlackBerry 9900; en) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.1.0.346 Mobile Safari/534.11+"
                            },
                            Option {
                                text: qsTr("BlackBerry 10")
                                value: "Mozilla/5.0 (BB10; Kbd) AppleWebKit/537.10+ (KHTML, like Gecko) Version/10.1.0.4633 Mobile Safari/537.10+"
                            }
                        ]
                        onSelectedIndexChanged: {
                            _app.setv("useragentid", selectedIndex);
                        }
                        onSelectedValueChanged: {
                            _app.setv("useragent", selectedValue)
                        }
                        title: qsTr("Selected UA:")
                    }

                    Label {
                        text: qsTr("Download Manager")
                        bottomMargin: 20.0
                        textStyle.fontWeight: FontWeight.W100
                        textStyle.fontSize: FontSize.Large
                        visible: false
                    }
                    Label {
                        text: qsTr("File type to monitor:")
                        textStyle.fontWeight: FontWeight.W100
                        visible: false

                    }
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight

                        }
                        visible: false
                        TextField {
                            text: _app.getv("ext", "zip;txt;apk;jpg;png;mp3")
                            hintText: qsTr("Example: zip;txt;apk...")
                            id: ext_text

                        }
                        Button {
                            preferredWidth: 1.0
                            appearance: ControlAppearance.Primary
                            imageSource: "asset:///icon/ic_done.png"
                            onClicked: {
                                _app.setv("ext", ext_text.text);
                            }

                        }
                    }
                    Label {
                        text: qsTr("Download files to:")
                        textStyle.fontWeight: FontWeight.W100
                        visible: false

                    }
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight

                        }
                        visible: false
                        TextField {

                            hintText: qsTr("Choose a path")
                            id: download_path_text
                            text: _app.getv("downloadpath", "/accounts/1000/shared/downloads")
                            onTextChanged: {
                                _app.setv("downloadpath", text);
                            }
                        }
                        Button {
                            imageSource: "asset:///icon/ic_edit.png"
                            appearance: ControlAppearance.Primary
                            preferredWidth: 1.0
                            verticalAlignment: VerticalAlignment.Center
                            attachedObjects: [
                                FilePicker {
                                    mode: FilePickerMode.SaverMultiple
                                    type: FileType.Other
                                    title: qsTr("Choose a path for download")
                                    defaultType: FileType.Other
                                    viewMode: FilePickerViewMode.ListView
                                    sortBy: FilePickerSortFlag.Name
                                    sortOrder: FilePickerSortOrder.Ascending
                                    id: fpd
                                    onFileSelected: {
                                        if (selectedFiles.length > 0) {
                                            download_path_text.text = selectedFiles[0];
                                        }
                                    }
                                }
                            ]
                            onClicked: {
                                fpd.open()
                            }

                        }
                    }
                }

                Header {
                    title: qsTr("GENERAL SETTINGS")
                }
                Container {
                    topPadding: 20.0
                    leftPadding: 20.0
                    bottomPadding: 20.0
                    rightPadding: 20.0
                    Label {
                        text: qsTr("Startup")
                        textStyle.fontWeight: FontWeight.W400
                        textStyle.fontSize: FontSize.Large
                    }
                    Label {
                        text: qsTr("When app starts, show:")
                        textStyle.fontWeight: FontWeight.W100
                    }
                    SegmentedControl {
                        options: [
                            Option {
                                text: qsTr("Start Page")
                            },
                            Option {
                                text: qsTr("Homepage")
                            },
                            Option {
                                text: qsTr("Blankpage")
                            }
                        ]
                        selectedIndex: parseInt(_app.getv("startup", "0"))
                        onSelectedIndexChanged: {
                            _app.setv("startup", selectedIndex)
                        }
                    }
                }
                Divider {

                }
                Container {
                    topPadding: 20.0
                    leftPadding: 20.0
                    bottomPadding: 20.0
                    rightPadding: 20.0
                    Label {
                        text: qsTr("Cache Management")
                        textStyle.fontWeight: FontWeight.W400
                        textStyle.fontSize: FontSize.Large
                    }
                    Label {
                        text: qsTr("When app exits :")
                        textStyle.fontWeight: FontWeight.W100
                    }
                    Container {
                        preferredWidth: Infinity
                        layout: GridLayout {
                            columnCount: 2
                        }
                        horizontalAlignment: HorizontalAlignment.Fill
                        Container {
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight

                            }
                            verticalAlignment: VerticalAlignment.Center
                            CheckBox {
                                checked: _app.getv("clearcache", "false") === "true"
                                onCheckedChanged: {
                                    _app.setv("clearcache", checked)
                                }

                                verticalAlignment: VerticalAlignment.Center

                            }
                            Label {
                                text: qsTr("Clear Cache")
                                horizontalAlignment: HorizontalAlignment.Left
                                verticalAlignment: VerticalAlignment.Center
                            }
                        }
                        Button {
                            text: qsTr("Clear Now")
                            preferredWidth: 1.0
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Center
                            onClicked: {
                                configwebview.storage.clear();
                                sst.body = qsTr("Cache Cleared");
                                sst.show();
                                console.log("CACHE CLEARED.");
                            }
                        }
                        Container {
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight

                            }
                            verticalAlignment: VerticalAlignment.Center
                            CheckBox {
                                checked: _app.getv("clearhistory", "false") === "true"
                                onCheckedChanged: {
                                    _app.setv("clearhistory", checked)
                                }
                                verticalAlignment: VerticalAlignment.Center
                                horizontalAlignment: HorizontalAlignment.Left
                            }
                            Label {
                                text: qsTr("Clear Histories")
                                verticalAlignment: VerticalAlignment.Center
                                horizontalAlignment: HorizontalAlignment.Left
                            }
                        }
                        Button {
                            text: qsTr("Clear Now")
                            preferredWidth: 1.0
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Center
                            onClicked: {
                                _app.clearHistories();
                                sst.body = "Histories Cleared"
                                sst.show();
                                console.log("HISTORY CLEARED.");
                            }
                        }
                        Container {
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight

                            }
                            verticalAlignment: VerticalAlignment.Center
                            visible: false
                            CheckBox {

                                checked: _app.getv("clearpassword", "false") === "true"
                                onCheckedChanged: {
                                    _app.setv("clearpassword", checked)
                                }
                                verticalAlignment: VerticalAlignment.Center
                            }
                            Label {
                                text: qsTr("Clear Saved Passwords")
                                verticalAlignment: VerticalAlignment.Center
                                horizontalAlignment: HorizontalAlignment.Left
                            }
                        }
                        Button {
                            text: qsTr("Clear Now")
                            preferredWidth: 1.0
                            verticalAlignment: VerticalAlignment.Center
                            horizontalAlignment: HorizontalAlignment.Right
                            visible: false
                        }
                    }

                }
                Divider {

                }
                Container {
                    topPadding: 20.0
                    leftPadding: 20.0
                    bottomPadding: 20.0
                    rightPadding: 20.0
                    Label {
                        text: qsTr("Configurations")
                        textStyle.fontWeight: FontWeight.W400
                        textStyle.fontSize: FontSize.Large
                    }
                    Label {
                        text: qsTr("In case you want a fresh install, here's a red button :")
                        textStyle.fontWeight: FontWeight.W100
                        multiline: true
                    }
                    Button {
                        text: qsTr("RESET")
                        color: Color.Red
                        horizontalAlignment: HorizontalAlignment.Center

                        onClicked: {
                            sdreset.show();
                        }
                        attachedObjects: [
                            SystemDialog {
                                id: sdreset
                                title: qsTr("RESET")
                                body: qsTr("This will reset all settings, histories, bookmarks. Are you sure?")
                                returnKeyAction: SystemUiReturnKeyAction.Submit
                                modality: SystemUiModality.Application
                                includeRememberMe: false
                                onFinished: {
                                    if (value == SystemUiResult.ConfirmButtonSelection) {
                                        configwebview.storage.clear();
                                        _app.clearBookmarks();
                                        _app.clearHistories();
                                        _app.clearSettings();
                                        console.log(qsTr("APP RESETED."));
                                        sst.body = qsTr("App Reseted");
                                        sst.show();
                                    }
                                }
                            }
                        ]
                    }
                    Label {
                        text: qsTr("*This will remove all your configurations includes: bookmarks, app cache, web histories, saved passwords, etc.")
                        textStyle.fontWeight: FontWeight.W100
                        multiline: true
                    }
                }
            }
        }
    }
}