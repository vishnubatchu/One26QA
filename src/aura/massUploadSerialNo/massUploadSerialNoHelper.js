({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        var opt_startByte ;
        var opt_stopByte ;
        // get the first file using array index[0] 
        var files =  component.find("fileId").get("v.files");
        var file = files[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        if (!files.length) {
            alert('Please select a file!');
            return;
        }
        var start = parseInt(opt_startByte) || 0;
        var stop = parseInt(opt_stopByte) || file.size - 1;
        var reader = new FileReader();
        reader.onloadend = function(evt) {
            if (evt.target.readyState == FileReader.DONE) { 
                var Strings = evt.target.result;
                var action = component.get("c.parseCSV");
                action.setParams({
                    contents: Strings,
                    skipHeaders:$A.get("$Label.c.SkipHeaderInCSVFile"),
                    caseID     : component.get('v.recID')
                    
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                   
                    if (state === "SUCCESS") {
                        
                        component.set("v.showLoadingSpinner", false);
                        if(response.getReturnValue() === 'SUCCESS'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'SUCCESS',
                                type: 'SUCCESS',
                                mode:'sticky',
                                message: 'SUCCESS'
                            });
                            toastEvent.fire();
                            location.reload();   
                        }
                        else{
                           
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'ERROR',
                                type: 'ERROR',
                                message: response.getReturnValue(),
                                mode:'sticky',
                            });
                            toastEvent.fire();
                        }
                        
                    }
                    if(state==='ERROR')
                    {
                        component.set('v.errormessages',true);
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'ERROR',
                                type: 'ERROR',
                                 mode:'sticky',
                                message: response.getReturnValue()
                            });
                            toastEvent.fire();
                    }
                });
                // enqueue the action
                $A.enqueueAction(action);
            }
        };
        var blob = file.slice(start, stop + 1);
        reader.readAsBinaryString(blob);
        
        
    }
})