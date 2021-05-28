({
    init : function(component, event, helper) {
        var flow =component.find('extensionFlow');
        var inputVariables =[{name:'recordId' ,type:'String', value:component.get('v.recordId')}];
        flow.startFlow('createLoanerextension',inputVariables);
    },
    onFinish :function(component,event)
    {
        
        
        if(event.getParam("status") === "FINISHED"   ) 
        {
            
            console.log(JSON.stringify(event.getParam('outputVariables')) +'flow status  '+event.getParam('status') +'flow Name'+ event.getParam('flowTitle'));
            var navigationLink = $A.get('e.force:navigateToSObject');
            var outputVariables = event.getParam('outputVariables');
            var setnavigationLink= false;
            var navigationObjectRecId;
            
            for(var i=0;i<outputVariables.length;i++)
            { 
                
                if(outputVariables[i].name === 'extensionRequest')
                {
                    if(outputVariables[i].value != null)
                    {
                        if(typeof(outputVariables[i].value.Id) != 'undefined'){
                            //navigationObjectRecId=outputVariables[i].value.Id;
                            var extensionRequestObj = outputVariables[i].value;
                            component.set('v.extensionRequest',extensionRequestObj);
                            //console.log('extension request',component.get('v.extensionRequest'));
                            setnavigationLink = true;}
                    }
                }
            }
            
            if(setnavigationLink){
                component.set('v.ApprovalSection',true);
                
            }
            if(!setnavigationLink)
            {
                $A.get("e.force:closeQuickAction").fire();
            }
            
        }
        else if(event.getParam("status") === 'ERROR')
        {
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    doCancel: function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    },
})