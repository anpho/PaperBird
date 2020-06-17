import bb.cascades 1.4

Tab {
    id: tabroot
    title: pageroot.title || qsTr("Untitled")
    imageSource: "asset:///icon/ca_browser.png"
    description: uri
    signal request_new_window(string targeturl); //open a new window
    signal request_close(variant thistab); //request to close this tab
    signal request_tabs_display()
    signal request_bookmark_view()
    signal request_history_view()
    signal request_next_tab();
    // page url
    property alias uri: pageroot.uri
    function loadurl(u){
        uri = u
        pageroot.uriChanged()
    }
    WebPage {
        id: pageroot
        onRequest_close_: {
            request_close(tabroot)
        }
        onRequest_new_window_: {
            request_new_window(targeturl)
        }
        onRequest_tabs: {
            request_tabs_display()
        }
        onRequest_bookmarkview: {
            request_bookmark_view()
        }
        onRequest_historyview: {
            request_history_view()
        }
        onRequest_nextTab: {
            request_next_tab();
        }
    }

}