({
    // Generating Pdf  through VisualForce Page
    downloadPdfFile : function(component,event,helper){
        var selectedValues = component.get("v.selectedGenreList"); //pass this value into vf page
        var recid = component.get('v.recordId'); //pass this value into vf page
        window.setTimeout(
            $A.getCallback(function() {
                // visualforce page URL
                window.location="/apex/FAAndFVReport?orderLine="+recid+"&selectedSerialNumber="+selectedValues;
            }), 1000
        );
    }
})