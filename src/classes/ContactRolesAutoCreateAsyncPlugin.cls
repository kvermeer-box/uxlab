global without sharing class ContactRolesAutoCreateAsyncPlugin implements FCRM.FCR_ExtensibilityAPI.IExtensibilityPlugin  {

    public static final String TIMEDASYNC = 'TimedAsync';   
    
    global Set<String> RequestedAPIs() { return new Set<String>{TIMEDASYNC} ;}   

    global String GetUniqueName() { return 'ContactRolesAutoCreateAsyncPlugin' ;}
    
    global Map<String,Set<String>> RequestedFields() 
    { 
        return new Map<String, Set<String>>();
    }    
    
    global void ExtensibilityEvent(String eventname, FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args) {

        if (eventname == TIMEDASYNC && args.getXMLdata() != null)
        {
            List<String> taskIds = args.getXMLdata().split(',');
            Map<Id, Task> taskList = new Map<Id, Task>([Select Id, WhatId, WhoId, Exclude_From_Contact_Role__c 
            	From Task Where Id IN : taskIds]);
            ContactRolesAutoCreate.autoCreate(taskList);
        } 
        
        return;
            
        
    }


}