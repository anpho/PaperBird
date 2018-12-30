import bb.cascades 1.4
import bb.system 1.2
import cn.anpho 1.0
import bb.platform 1.3
Page {
    signal request_new_window_(string targeturl); //open a new window
    signal request_close_(); //request to close this tab
    signal request_tabs()
    signal request_bookmarkview()
    signal request_historyview()
    signal request_nextTab()
    property alias title: webv.title
    property string uri: ""
    onUriChanged: {
        if (uri.trim().length == 0) {
            //            bottomlabel.visible = true;
            showbottomlabel.play()
            address_text_input.requestFocus();
        } else if (uri.indexOf(":") > 0) {
            webv.url = uri
        } else if (uri.indexOf(".") > 0) {
            webv.url = "http://" + uri
        } else {
            webv.url = _app.getv("searchurl", "http://bing.com/search?q=%1").arg(uri);
        }
    }
    property bool showImages: _app.getv("showimage", "true") == "true"
    id: pageroot
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {
        }
        Container {
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
            property double lasty
            signal swipeup
            signal swipedown
            onTouch: {
                if (event.isDown()) {
                    // log the init point
                    lasty = event.localY
                } else if (event.isUp()) {
                    var cury = event.localY
                    console.log(cury - lasty)
                    if (cury - lasty > 300) {
                        swipedown()
                    } else if (cury - lasty < -20) {
                        swipeup()
                    }
                }
            }
            onSwipedown: {
                //show address bar
                showbottomlabel.play()
            }
            onSwipeup: {
                //hide address bar
                hidebottomlabel.play()
            }
            
            ScrollView {
                id: sv
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Fill

                scrollViewProperties {
                    scrollMode: ScrollMode.Vertical
                    pinchToZoomEnabled: true
                }
                onContentScaleChanged: {
                    if (contentScale > 1) {
                        scrollViewProperties.scrollMode = ScrollMode.Both
                    } else {
                        scrollViewProperties.scrollMode = ScrollMode.Vertical
                    }
                }
                builtInShortcutsEnabled: true
                scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.None
                scrollRole: ScrollRole.Main
                WebView {
                    id: webv
//                    url: "local:///assets/blank"
                    horizontalAlignment: HorizontalAlignment.Fill
                    onUrlChanged: {

                    }
                    verticalAlignment: VerticalAlignment.Fill
                    preferredHeight: Infinity
                    onMinContentScaleChanged: {
                        sv.scrollViewProperties.minContentScale = minContentScale;
                    }
                    onMaxContentScaleChanged: {
                        sv.scrollViewProperties.maxContentScale = maxContentScale;
                    }
                    onLoadingChanged: {
                    }
                    onTitleChanged: {
                        if (webv.title.toString().trim().length == 0) {
                            return;
                        }
                        var item = {
                            "title": webv.title,
                            "url": webv.url.toString()
                        }
                        var pos = webadm.indexOf(item);
                        if (pos > -1) {
                            webadm.replace(pos, item);
                        } else {
                            webadm.append(item)
                        }
                    }
                    attachedObjects: [
                        ArrayDataModel {
                            id: webadm
                            onItemAdded: {
                                var current = webadm.data(indexPath);
                                console.log(current.title + current.url)
                                _app.updateHistoryByURI(current.title, current.url);
                            }
                        }
                    ]
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                if (webv.settings.userStyleSheetLocation != ""){
                                    webv.settings.userStyleSheetLocation = "";
                                    sstt.body = qsTr("Text Selection Enabled");
                                    sstt.show();
                                }else{
                                    webv.settings.userStyleSheetLocation = "asset:///disable_selection.css";
                                    sstt.body = qsTr("Text Selection Disabled");
                                    sstt.show();
                                }
                            }
                        }
                    ]
                    onNavigationRequested: {
                        if (request.navigationType == WebNavigationType.OpenWindow) {
                            request.action = WebNavigationRequestAction.Ignore
                            request_new_window_(request.url)
                        } else {
                            sv.resetScale()
                        }
                    }
                    settings.userAgent: _app.getv("useragent", "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.83 Mobile Safari/537.36 PaperBird")
                    settings.zoomToFitEnabled: true
                    settings.activeTextEnabled: true
                    settings.credentialAutoFillEnabled: true
                    settings.formAutoFillEnabled: true
                    onNewViewRequested: {
                        request.openIn(invisible_webview);
                        request_new_window_(invisible_webview.url)
                        invisible_webview.stop()
                    }
                    implicitLayoutAnimationsEnabled: false
                    settings.userStyleSheetLocation: "asset:///disable_selection.css"
                    settings.imageDownloadingEnabled: showImages
                }
                scrollViewProperties.initialScalingMethod: ScalingMethod.AspectFill
                implicitLayoutAnimationsEnabled: false

            }
            Container {
                verticalAlignment: VerticalAlignment.Top
                horizontalAlignment: HorizontalAlignment.Fill
                background: Color.Black
                layout: DockLayout {

                }
                Label {
                    text: webv.loading ? webv.url : webv.title
                    textStyle.fontSize: FontSize.XXSmall
                    textStyle.color: Color.White
                    horizontalAlignment: HorizontalAlignment.Fill
                }
                ProgressIndicator {
                    value: webv.loadProgress
                    toValue: 100.0
                    horizontalAlignment: HorizontalAlignment.Fill
                    preferredHeight: 1.0
                    visible: value < 99
                    verticalAlignment: VerticalAlignment.Bottom
                    opacity: 0.7
                }
                onTouch: {
                    showbottomlabel.play()
                    address_text_input.requestFocus()
                }
            }
        }
        Container {
            id: bottomlabel
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            verticalAlignment: VerticalAlignment.Bottom
            horizontalAlignment: HorizontalAlignment.Fill
            background: Color.Black
            ImageView {
                imageSource: "asset:///icon/ic_tab.png"
                scalingMethod: ScalingMethod.AspectFit
                loadEffect: ImageViewLoadEffect.None
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Left
                scaleX: 0.8
                scaleY: 0.8
                gestureHandlers: TapHandler {
                    onTapped: {
                        request_tabs()
                    }
                }
                id: showtab_image
            }
            ImageButton {
                defaultImageSource: "asset:///icon/ic_previous.png"
                scaleX: 0.8
                scaleY: 0.8
                pressedImageSource: "asset:///icon/ic_previous.png"
                visible: webv.canGoBack
                gestureHandlers: TapHandler {
                    onTapped: {
                        webv.goBack()
                    }
                }
            }
            TextField {
                id: address_text_input
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Fill
                hintText: qsTr("Type URL here")
                text: webv.url.toString().toLowerCase().indexOf("local:///assets") > -1 ? "" : webv.url
                textFormat: TextFormat.Plain
                inputMode: TextFieldInputMode.Url
                autoFit: TextAutoFit.None
                input.submitKey: SubmitKey.Go
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                input.keyLayout: KeyLayout.Url
                backgroundVisible: false
                implicitLayoutAnimationsEnabled: false
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1.0
                }
                input.onSubmitted: {
                    if (text.length > 0) uri = text;
                    hidebottomlabel.play()
                }
                textStyle.color: Color.White
                onFocusedChanged: {
                    if (focused) {
                        editor.setSelection(0, text.length);
                    }else {
                        hidebottomlabelwithDealy.play()
                    }
                }
            }
            ImageView {
                imageSource: "asset:///icon/ic_overflow_action.png"
                scalingMethod: ScalingMethod.AspectFit
                loadEffect: ImageViewLoadEffect.None
                scaleX: 0.8
                scaleY: 0.8
                gestureHandlers: TapHandler {
                    onTapped: {
                        pageroot.openActionMenu()
                    }
                }
            }
        }
        Container {
            id: top_close
            verticalAlignment: VerticalAlignment.Top
            horizontalAlignment: HorizontalAlignment.Right
            topPadding: ui.du(1)
            leftPadding: ui.du(1)
            bottomPadding: ui.du(1)
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight

                }
                rightPadding: ui.du(2.0)
                ImageView {
                    imageSource: "asset:///icon/close.png"
                    scalingMethod: ScalingMethod.AspectFit
                    scaleX: 0.8
                    scaleY: 0.8
                    verticalAlignment: VerticalAlignment.Center
                    filterColor: Color.White
                    preferredWidth: ui.du(6.0)
                    preferredHeight: ui.du(6.0)
                }
                gestureHandlers: TapHandler {
                    onTapped: {
                        sd.exec()
                    }
                }
            }

        }
//        Container {
//            visible: webv.loading
//            horizontalAlignment: HorizontalAlignment.Center
//            verticalAlignment: VerticalAlignment.Top
//            layout: StackLayout {
//                orientation: LayoutOrientation.LeftToRight
//            }
//            background: Color.create("#77000000")
//            leftPadding: 40.0
//            rightPadding: 40.0
//            topPadding: 10.0
//            bottomPadding: 10.0
//            ActivityIndicator {
//                running: true
//            }
//            Label {
//                text: qsTr("Loading...")
//                textStyle.color: Color.White
//            }
//        }
    }
    actions: [
        DeleteActionItem {
            title: qsTr("Close")
            onTriggered: {
                sd.exec()
            }

            ActionBar.placement: ActionBarPlacement.InOverflow
            shortcuts: [
                Shortcut {
                    key: "w"
                }
            ]
        },
        ActionItem {
            title: qsTr("Go Back")
            imageSource: "asset:///icon/ic_previous.png"
            enabled: webv.canGoBack
            onTriggered: {
                webv.goBack()
            }
            shortcuts: Shortcut {
                key: "p"
            }
        },
        ActionItem {
            title: qsTr("Go Forward")
            imageSource: "asset:///icon/ic_next.png"
            enabled: webv.canGoForward
            onTriggered: {
                webv.goForward()
            }
            shortcuts: Shortcut {
                key: "n"
            }
        },
        ActionItem {
            title: qsTr("Lock Oriention")
            onTriggered: {
                lockscreendialog.init()
            }
            shortcuts: Shortcut {
                key: "Alt+L"
            }
            attachedObjects: [
                SystemListDialog {
                    function init() {
                        // setup the list
                        lockscreendialog.clearList();
                        lockscreendialog.appendItem(qsTr("Lock Landscape"));
                        lockscreendialog.appendItem(qsTr("Lock Portrait"));
                        lockscreendialog.appendItem(qsTr("Not Locked"));
                        show();
                    }
                    id: lockscreendialog
                    includeRememberMe: false
                    rememberMeChecked: false
                    customButton.enabled: false
                    confirmButton.enabled: true
                    cancelButton.enabled: true
                    returnKeyAction: SystemUiReturnKeyAction.Done
                    title: qsTr("Rotation Lock")
                    body: qsTr("If you want to lock the screen rotation, check it here. All settings will be reseted when app exits.")
                    onFinished: {
                        console.log(value)
                        console.log(selectedIndices)
                        if (value == SystemUiResult.ConfirmButtonSelection) {
                            switch (selectedIndices[0]) {
                                case 0:
                                    OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.DisplayLandscape
                                    break;
                                case 1:
                                    OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.DisplayPortrait
                                    break;
                                case 2:
                                    OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All
                                    break;
                            }
                        }
                    }
                }
            ]
            imageSource: "asset:///icon/rotate.png"
        },
        ActionItem {
            title: qsTr("Add Bookmark")
            imageSource: "asset:///icon/ic_add_bookmarks.png"
            onTriggered: {
                var result = _app.addBookmark(webv.title, webv.url);
                if (result) {
                    sstt.body = qsTr("Bookmark Created");
                    sstt.show();
                } else {
                    sstt.body = qsTr("Bookmark Creation Failed")
                    sstt.show();
                }
            }
            shortcuts: [
                Shortcut {
                    key: "Alt+F"
                }
            ]
        },
        ActionItem {
            title: qsTr("Set Homepage")
            imageSource: "asset:///icon/ic_homex.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                _app.setv("homepage", webv.url)
                sstt.body = qsTr("Homepage Set")
                sstt.show();
            }
            shortcuts: [
                Shortcut {
                    key: "Alt+H"
                }
            ]
        },
        ActionItem {
            title: qsTr("Pin to Homescreen")
            imageSource: "asset:///icon/ic_homex.png"            
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                var absheet = Qt.createComponent("Pin2Home.qml").createObject(pageroot);
                absheet.title = webv.title;
                absheet.url = webv.url;
                absheet.open();
            }
        },
        ActionItem {
            imageSource: showImages ? "asset:///icon/ic_cancel.png" : "asset:///icon/ic_view_image.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                showImages = ! showImages;
                _app.setv("showimage", showImages);
            }
            title: showImages ? qsTr("Disable Images") : qsTr("Enable Images")

        },
        ActionItem {
            title: qsTr("Stop")
            imageSource: "asset:///icon/ic_cancel.png"
            enabled: webv.loading
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                webv.stop()
            }
            shortcuts: Shortcut {
                key: "s"
            }
        },
        ActionItem {
            title: qsTr("Reload")
            onTriggered: {
                webv.reload();
            }
            imageSource: "asset:///icon/ic_reload.png"
            shortcuts: Shortcut {
                key: "r"
            }
        },
        ActionItem {
            title: qsTr("Share URL")
            imageSource: "asset:///icon/ic_share.png"
            onTriggered: {
                var text_template = qsTr("Check this out: ") + (webv.title) + " - " + (webv.url);
                console.log(text_template);
                _app.shareText(text_template)
            }
            shortcuts: [
                Shortcut {
                    key: "$"
                },
                Shortcut {
                    key: "Alt+s"
                }
            ]
        },
        ActionItem {
            title: qsTr("Open with ... ")
            onTriggered: {
                _app.openWith(webv.url);
            }
            imageSource: "asset:///icon/ic_browser.png"
        },
        ActionItem {
            title: qsTr("URL")
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///icon/URL.png"
            onTriggered: {
                showbottomlabel.play()
                //                bottomlabel.visible = true
                address_text_input.requestFocus()
            }
            shortcuts: Shortcut {
                key: "g"
            }
        },
        ActionItem {
            onTriggered: {
                request_bookmarkview()
            }
            shortcuts: Shortcut {
                key: "Alt+B"
            }
            title: qsTr("Show Bookmarks")
            imageSource: "asset:///icon/ic_view_list.png"
        },
        ActionItem {
            onTriggered: {
                request_historyview()
            }

            shortcuts: Shortcut {
                key: "Alt+H"
            }
            title: qsTr("Show Histories")
            imageSource: "asset:///icon/ic_history.png"
        },
        ActionItem {
            onTriggered: {
                request_nextTab()
            }
            shortcuts: Shortcut {
                key: "Alt+Z"
            }
            imageSource: "asset:///icon/ic_nav_to.png"
            title: qsTr("Next Tab")
        }
    ]
    attachedObjects: [
        WebView {
            id: invisible_webview
        },
        SystemToast {
            id: sstt
            position: SystemUiPosition.BottomCenter
        },
        TranslateTransition {
            id: hidebottomlabel
            target: bottomlabel
            toY: 300
            onStarted: {
                hidetoplabel.play()
            }
        },
        TranslateTransition {
            id: hidebottomlabelwithDealy
            target: bottomlabel
            toY: 300
            onStarted: {
                hidetoplabel.play()
            }
            delay: 2000
        },
        TranslateTransition {
            id: showbottomlabel
            target: bottomlabel
            toY: 0
            onStarted: {
                showtoplabel.play()
            }
            onEnded: {
                
            }
        },
        ParallelAnimation {
            // 隐藏右上角关闭按钮
            id: hidetoplabel
            target: top_close
            animations: [
                TranslateTransition {
                    toX: 150
                },
                RotateTransition {
                    toAngleZ: 180
                }
            ]
        },
        ParallelAnimation {
            // 在1秒后隐藏右上角的关闭按钮
            id: hidetoplabelwithDelay
            target: top_close
            animations: [
                TranslateTransition {
                    toX: 150
                },
                RotateTransition {
                    toAngleZ: 180
                }
            ]
            delay: 1000
        },
        ParallelAnimation {
            // 显示右上角的关闭按钮，并在1秒后隐藏
            id: showtoplabel
            target: top_close
            animations: [
                TranslateTransition {
                    toX: 0
                },
                RotateTransition {
                    toAngleZ: 0
                }
            ]
            onEnded: {
                hidetoplabelwithDelay.play()
            }
        },

        SystemDialog {
            id: sd
            title: qsTr("Confirm")
            body: qsTr("Do you want to close current Tab?")
            includeRememberMe: false
            customButton.enabled: false
            onFinished: {
                if (value == SystemUiResult.ConfirmButtonSelection) {
                    request_close_()
                }
            }
        }
    ]
    actionBarVisibility: ChromeVisibility.Hidden
    onCreationCompleted: {
        if (uri.length == 0) {
            //            bottomlabel.visible = true;
            showbottomlabel.play()
            address_text_input.requestFocus();
        }
    }
}
