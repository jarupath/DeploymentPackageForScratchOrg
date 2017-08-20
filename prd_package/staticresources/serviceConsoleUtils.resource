function openNewTab(recordId) {
    if(sforce.one){
        sforce.one.navigateToSObject(recordId);
    } else {
        sforce.console.getEnclosingPrimaryTabId(function(result){
            var primaryTabId = result.id;
            sforce.console.openSubtab(primaryTabId , '/'+recordId, true, "", null, null, null);
        });
    }
}

function closeTab() {
    //First find the ID of the current tab to close it
    sforce.console.getEnclosingTabId(closeSubtab);
}

var closeSubtab = function closeSubtab(result) {
    //Now that we have the tab ID, we can close it
    console.log(result);
    var tabId = result.id;
    sforce.console.closeTab(tabId);
};