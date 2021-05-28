({
    /* This method will be called once the component renders into DOM.
     * This method uses the maxLength Attribute and pageLimit to generate the list of buttons including the page Number
     * and checks the number of the buttons if there more than 10 buttons .. next >> and << prev  will be enabled
     * based on the maxLength , updates the lastPage value*/
    doinit : function(component, event, helper) {
      
        var len			=component.get("v.PageLimit");
        var buttonList	=[];
        var currentPage =1+(component.get("v.startPoint") * len);        
        var lastPage	=parseInt(component.get("v.maxLength") / len);
        component.set("v.nextFiveButtonCounter",component.get("v.ButtonLimit"));
        if(component.get("v.maxLength")  % len == 0 ){
            component.set("v.lastPage",lastPage);
        }else{
            component.set("v.lastPage",(lastPage+1));
        } 
        for(var i=0;i<component.get("v.maxLength");i++){
            if(i%len==0){                
                buttonList.push((i/len)+1);                
            }
        }        
        component.set("v.ButtonListMaster",buttonList);        
        if(buttonList.length > component.get("v.ButtonLimit")){
            component.set("v.nextFlag10",false);
        }
    },
    /* This method will be called once the user clicks on the page number 
     * Based on the page Number ,StartPoint and endPoint attributs values will be updated.
     * Checks the availibilty of the << prev,  prev, next, next>> buttons and updates the corresponding flags  
     */
    goPage:function(component, event, helpe){        
        var pageNumber	=Number(event.getSource().get("v.name"));
        
        var plimit		=component.get("v.PageLimit");    
        console.log(pageNumber+'  plimit'+plimit);
        component.set("v.startPoint",(0+(pageNumber *plimit)));
        component.set("v.endPoint",(plimit+(pageNumber *plimit)));        
        if(component.get("v.maxLength") <= component.get("v.endPoint")){
            component.set("v.nextFlag",true);
        }else{
            component.set("v.nextFlag",false);
        }
        if(component.get("v.startPoint") < component.get("v.PageLimit")){
            component.set("v.preFlag",true);
        }else{
            component.set("v.preFlag",false);
        }
        var currentPage=1+parseInt(component.get("v.maxLength") % component.get("v.startPoint") );
        component.set("v.currentPage",(pageNumber+1));
        
        var setStartandEndPointEvent = component.getEvent('setStartandEndPointEvent');
        setStartandEndPointEvent.setParams({
            'startPoint': component.get("v.startPoint"),
            'endPoint': component.get("v.endPoint")
        });
        setStartandEndPointEvent.fire();
        
    },
    
    /* This method will be called once the user clicks on the next button and  
     * Addes page limit to StartPoint and endPoint attributs values.
     * Checks the availibilty of the << prev,  prev, next, next>> buttons and updates the corresponding flags  
     */
    next:function(component, event, helper) {
        var max			=	component.get("v.maxLength");
        var nextbutton 	= 	component.find('nex');
        var plimit		=	component.get("v.PageLimit");
        var st			=	component.get("v.startPoint");
        var ep			=	component.get("v.endPoint");
        component.set("v.startPoint",(st+plimit));
        component.set("v.endPoint",(ep+plimit));
        var st1			=	component.get("v.startPoint");
        var ep1			=	component.get("v.endPoint");
        
        if(max <= ep1){        
            component.set("v.nextFlag",true);
        } 
        component.set("v.preFlag",false);
        var currentPage=parseInt(component.get("v.endPoint") / plimit );
        component.set("v.currentPage",currentPage);
        if(st1==(component.get("v.nextFiveButtonCounter")* plimit)){
            component.set("v.nextFiveButtonCounter",(component.get("v.nextFiveButtonCounter")+component.get("v.ButtonLimit")));        
            component.set("v.preFiveButtonCounter",(component.get("v.preFiveButtonCounter")+component.get("v.ButtonLimit")));
            component.set("v.preFlag10",false);
        }        
        if(component.get("v.ButtonListMaster").length <= component.get("v.nextFiveButtonCounter")){
            component.set("v.nextFlag10",true);           
        }  
    },
    /* This method will be called once the user clicks on the previous button.  
     * Reduces the StartPoint and endPoint attributs values by page limit.
     * Checks the availibilty of the << prev,  prev, next, next>> buttons and updates the corresponding flags  
     */
    prev:function(component, event, helper) {
        var plimit=component.get("v.PageLimit");
        component.set("v.startPoint",(component.get("v.startPoint")-plimit));
        component.set("v.endPoint",(component.get("v.endPoint")-plimit));
        if(component.get("v.startPoint") <= 0){
            component.set("v.preFlag",true); 
        }
        component.set("v.nextFlag",false);
        component.set("v.currentPage",(parseInt(component.get("v.endPoint") / plimit )));
        if(component.get("v.endPoint") == (component.get("v.preFiveButtonCounter")* plimit)){
            component.set("v.nextFiveButtonCounter",(component.get("v.nextFiveButtonCounter")-component.get("v.ButtonLimit")));        
            component.set("v.preFiveButtonCounter",(component.get("v.preFiveButtonCounter")-component.get("v.ButtonLimit")));
            component.set("v.nextFlag10",false);            
        }
        if(component.get("v.preFiveButtonCounter") == 0){
            component.set("v.preFlag10",true);            
        }        
    },
    /* This method will be called once the user clicks on the next >> button. 
     * Shows the next 10 page numbers.
     * StartPoint and endPoint attributs values will be updated accordingly .
     * Checks the availibilty of the << prev,  prev, next, next>> buttons and updates the corresponding flags  
     */
    next10buttons:function(component, event, helper) {
        var plimit=component.get("v.PageLimit");  
        if(component.get("v.nextFiveButtonCounter") < component.get("v.ButtonListMaster").length){  
            //set the range for new set of buttons  
            component.set("v.nextFiveButtonCounter",(component.get("v.nextFiveButtonCounter")+component.get("v.ButtonLimit")));        
            component.set("v.preFiveButtonCounter",(component.get("v.preFiveButtonCounter")+component.get("v.ButtonLimit")));
            component.set("v.preFlag10",false);
            //change start and end parameters accordingly 
            component.set("v.startPoint",(plimit * component.get("v.preFiveButtonCounter")));
            component.set("v.endPoint",(plimit+(plimit * component.get("v.preFiveButtonCounter"))));
        }
        if(component.get("v.ButtonListMaster").length <= component.get("v.nextFiveButtonCounter")){
            component.set("v.nextFlag10",true);            
        }
        var currentPage=parseInt(component.get("v.endPoint") / plimit );
        component.set("v.currentPage",currentPage);
    },
    /* This method will be called once the user clicks on the <<prev button. 
     * Shows the previous 10 page numbers.
     * StartPoint and endPoint attributs values will be updated accordingly .
     * Checks the availibilty of the << prev,  prev, next, next>> buttons and updates the corresponding flags  
     */
    pre10buttons:function(component, event, helper) {
        var plimit=component.get("v.PageLimit"); 
        if(component.get("v.preFiveButtonCounter") > 0){
            //set the range for new set of buttons   
            component.set("v.nextFiveButtonCounter",(component.get("v.nextFiveButtonCounter")-component.get("v.ButtonLimit")));        
            component.set("v.preFiveButtonCounter",(component.get("v.preFiveButtonCounter")-component.get("v.ButtonLimit")));
            component.set("v.nextFlag10",false); 
            //change start and end parameters accordingly 
            component.set("v.startPoint",(plimit * component.get("v.preFiveButtonCounter")));
            component.set("v.endPoint",(plimit+(plimit * component.get("v.preFiveButtonCounter"))));            
        }
        if(component.get("v.preFiveButtonCounter") == 0){
            component.set("v.preFlag10",true);
        }
        if(component.get("v.startPoint") <= 0 ){
            component.set("v.preFlag",true); 
        }
        component.set("v.currentPage",(parseInt(component.get("v.endPoint") / plimit )));
    },
    itemsChange :function(component,event)
    {
        console.log(' event occurs');
        var len			=component.get("v.PageLimit");
        var buttonList	=[];
        var currentPage =1+(component.get("v.startPoint") * len);        
        var lastPage	=parseInt(component.get("v.maxLength") / len);
        component.set("v.nextFiveButtonCounter",component.get("v.ButtonLimit"));
        if(component.get("v.maxLength")  % len == 0 ){
            component.set("v.lastPage",lastPage);
        }else{
            component.set("v.lastPage",(lastPage+1));
        } 
        for(var i=0;i<component.get("v.maxLength");i++){
            if(i%len==0){                
                buttonList.push((i/len)+1);                
            }
        }        
        component.set("v.ButtonListMaster",buttonList);        
        if(buttonList.length > component.get("v.ButtonLimit")){
            component.set("v.nextFlag10",false);
        }
    }
    
})