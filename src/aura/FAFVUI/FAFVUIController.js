({
	doInit : function(component, event, helper) {
        console.log('test!!!!!');
        // var myPageRef = component.get("v.pageReference");
        var recids = component.get("v.recordId");
        console.log('recids'+recids);
        var childCmp = component.find('childCmp1');
        childCmp.getRecID(recids);
      /**  var sParam = 'recID';
          var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                    sURLVariables = sPageURL.split('&'),
                    sParameterName,
                    i;

                for (i = 0; i < sURLVariables.length; i++) {
                    sParameterName = sURLVariables[i].split('=');
                    console.log('param13' + sParameterName);
                    if (sParameterName[0] === sParam) {
                      
		 var childCmp = component.find('childCmp1');
       // component.set("v.recID" ,component.get('v.recordId'));
       //childCmp.getRecID(sParameterName[1]); 
                        childCmp.getRecID(component.get('v.recID'));
                       
                    }
                }
        **/
     
	},
    closeUi : function(component, event,helper){
    window.close();
},
  openFVFA : function(component, event,helper){
    component.find('childCmp1').OpenFVFAPopUp();
},
    cloneFVFA : function(component, event,helper){
    component.find('childCmp1').CloneFAFV();
},
})