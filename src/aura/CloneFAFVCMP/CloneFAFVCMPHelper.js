({
    loadFAFVRecord : function(component,event,helper) {
        console.log('helper************'+component.get('v.FAFVRecordId'));
        console.log('Execution without Error Here++++++');
        var getFAFVRecordAction = component.get('c.getFAFVRecord');
        getFAFVRecordAction.setParams({
            'FAFVRecId' :component.get('v.FAFVRecordId')
        });
        getFAFVRecordAction.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
               // try{
                    console.log('Sucesss Block in clone');
                    console.log(response.getReturnValue());
                    var fafvName = response.getReturnValue();
                    var cloneToastMessage = $A.get("e.force:showToast");
                    cloneToastMessage.setParams({
                        "title":"Clone FA/FV",
                        "message": "Clone Successfully Record Name is "
                        //"messageTemplate": "Record {0} created! See it {1}!",
                        //"duration":"2000",
                        //"key": "info_alt",
                        //"type" : "success",
                        //mode: 'pester"
                    });
                    console.log('cloneToastMessage1',cloneToastMessage);
                    cloneToastMessage.fire();
               // }catch(err){
                 //   console.log('Exception e'+err.message);
                //}    			
            }
        });
        
        $A.enqueueAction(getFAFVRecordAction);
    }
})