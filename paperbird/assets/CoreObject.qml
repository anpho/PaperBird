import bb.cascades 1.4

QtObject {
    property TabbedPane tabhost
    property ComponentDefinition tabtemplate
    //    property Tab_History tabhistory
    function open_new_window(targeturl) {
        console.log("OPENING ... " + targeturl)
        /*
         * call this method to create a new tab.
         */
        var newtab = tabtemplate.createObject(tabhost)
        newtab.request_new_window.connect(open_new_window);
        newtab.request_close.connect(close_window);
        newtab.request_tabs_display.connect(show_tabs);
        newtab.request_bookmark_view.connect(show_bookmarks);
        newtab.request_history_view.connect(show_history);
        newtab.request_next_tab.connect(show_next_tab);
        tabhost.add(newtab);
        tabhost.activeTab = newtab;
        if (targeturl) {
            newtab.uri = targeturl;
        } else {
            newtab.uri = "";
        }
    }
    function close_window(handle) {
        /*
         * close the callee window and trigger the last one.
         */
        var pos = tabhost.indexOf(handle)
        tabhost.remove(handle)
        // active the left tab begin
        var newactivepos = tabhost.count() - 1;
        if (newactivepos == 3) {
            newactivepos = 0;
        }
        tabhost.activeTab = tabhost.at(newactivepos)
        tabhost.activeTab.triggered();
        // active the left tab end
    }
    function show_tabs() {
        /*
         * display the tabs
         */
        tabhost.sidebarState = SidebarState.VisibleFull
    }
    function show_bookmarks() {
        /*
         * show bookmark view
         */
        tabhost.activeTab = tabhost.at(0)
        tabhost.activeTab.triggered();
    }
    function show_history() {
        /*
         * show history view
         */
        tabhost.activeTab = tabhost.at(1)
        tabhost.activeTab.triggered();
    }
    function show_next_tab() {
        /*
         * navigate to the next tab.
         */
        var cur = tabhost.indexOf(tabhost.activeTab) - 3;
        var count = tabhost.count() - 3;
        var nextcur = (cur + 1) % count + 3;
        tabhost.activeTab = tabhost.at(nextcur)
        tabhost.activeTab.triggered();
    }
}
