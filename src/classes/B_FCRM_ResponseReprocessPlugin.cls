global without sharing class B_FCRM_ResponseReprocessPlugin implements FCRM.FCR_ExtensibilityAPI.IExtensibilityPlugin  {

    public static final String RESPONSEPREPROCESSING = 'ResponsePreprocessing'; // Hook to process responses after cascade evaluation but before save/update
        
    public Boolean IsRepeatUser {
        get {
            if (IsRepeatUser != null) return IsRepeatUser;
            return FCRM.FCR_SupportAPI.IsRepeatResponseUser(UserInfo.getUserId());
        }
        set;
    }
    
    // FieldSetMembers of custom fields Eloqua sets on the CampaignMember
    public List<Schema.FieldSetMember> eloquaFieldSetMembers {
        get {
            if (eloquaFieldSetMembers != null) return eloquaFieldSetMembers; 
            return Schema.SObjectType.CampaignMember.FieldSets.ELQ_Response_Fields.getFields();
        }
    }
    
    // Field paths of custom fields Eloqua sets on the CampaignMember
    public Set<String> eloquaFields {
        get {
            if (eloquaFields != null) return eloquaFields;
            Set<String> fieldPaths = new Set<String>();
            for (Schema.FieldSetMember fsm : eloquaFieldSetMembers) fieldPaths.add(fsm.getFieldPath());
            return fieldPaths;
        }
    }   
    
    global Set<String> RequestedAPIs() { return new Set<String>{RESPONSEPREPROCESSING} ;}   

    global String GetUniqueName() { return 'BoxResponseReprocessPlugin' ;}
    
    global Map<String,Set<String>> RequestedFields() 
    { 
        return new Map<String, Set<String>>{ 'CampaignMember'=> eloquaFields};
    }
    
    global void ExtensibilityEvent(String eventname, FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs args) {

        if (eventname == RESPONSEPREPROCESSING && IsRepeatUser)
        {
            system.debug('args' + args);
            if (args.getRecordLists().size() != 3 || args.getRecordMaps().size() != 3) return;
            
            Boolean isInsert = args.getRecordLists()[2] != null && args.getRecordLists()[2].size() > 0;       
            Boolean isUpdate = args.getRecordMaps()[2] != null && args.getRecordMaps()[2].size() > 0;  
            
            B_FCRM_ResponseReprocessSupport supportclass = new B_FCRM_ResponseReprocessSupport(eloquaFieldSetMembers, eloquaFields);
            if (isInsert)
            {   
                // Remove blanks from list of CampaignMembers that are being treated as responses during an insert operation.                               
                supportclass.clearBlankFields((List<CampaignMember>)args.getRecordLists()[2]);                                             
            }

            if (isUpdate)
            {               
                // A map of IDs to CampaignMembers that are being treated as responses during an update operation. 
                // The ID key represents the ID of the originating CampaignMember.      
                Map<Id, CampaignMember> updatedCmResponsesToProcess  = (Map<Id, CampaignMember>)args.getRecordMaps()[0];
                Map<Id, CampaignMember> repeatResponseByOrigCmId = new Map<Id, CampaignMember>();
                Set<Id> responsesToRevertOnly = new Set<Id>();
                Map<Id, CampaignMember> newMap = (Map<Id, CampaignMember>)args.getRecordMaps()[1];
                Map<Id, CampaignMember> oldMap = (Map<Id, CampaignMember>)args.getRecordMaps()[2]; 
                for (Id origCmId : updatedCmResponsesToProcess.keySet())
                {
                    CampaignMember response = updatedCmResponsesToProcess.get(origCmId);
                    if (response.Id == origCmId)
                    {
                        // IDs equal when the system updates response without inserting repeat responses. Only reverting fields is required.                  
                        if (newMap.get(origCmId).HasResponded) responsesToRevertOnly.add(origCmId);
                    }   
                    else
                    {
                        // Eloqua updated the originating response and created a repeat. 
                        // Need to revert old values on originating response and put its new values on the repeat response.   
                        repeatResponseByOrigCmId.put(origCmId, response);
                    }
                }

                // Reset originating non-responses 
                // NOTE: camapaign members with old status field value "Sent" and updated to "Responded", will still have HasResponded = false in this context
                List<CampaignMember> nonResponses = new List<CampaignMember>();
                if (args.getRecordLists()[0] != null) nonResponses.addAll((List<CampaignMember>)args.getRecordLists()[0]);
                if (args.getRecordLists()[1] != null) nonResponses.addAll((List<CampaignMember>)args.getRecordLists()[1]);
                
                for (CampaignMember cm : nonResponses)
                {
                    // Only originating responses have an id and only want to reset those
                    if (cm.Id != null && cm.HasResponded) responsesToRevertOnly.add(cm.Id);
                }
                
                // Set repeat field values equal to its originating's field values, then revert originating's field values to old values. 
                if (repeatResponseByOrigCmId.size() > 0) supportclass.setOrigFieldValuesOnRepeatAndRevertOrig(repeatResponseByOrigCmId, newMap, oldMap);

                // Reverts originating response's Eloqua field values back to its old values.
                if (responsesToRevertOnly.size() > 0) supportclass.revertOrigResponse(responsesToRevertOnly, newMap, oldMap);                
            }
        } 
        
        return;
    }
    
    public static Boolean revertToOrigResponseOnNoRepeatCalled = false;
    
    // Reverts response to orginal values when response is updated by eloqua and associated with a Campaign 
    // that does not allow repeat responses or the response's FCRM__FCR_Response_Status__c field equals 'Not a Response'
    public void revertToOrigResponseOnNoRepeat(Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap)
    {   
        if (IsRepeatUser && !revertToOrigResponseOnNoRepeatCalled)
        {
            revertToOrigResponseOnNoRepeatCalled = true;
            Set<Id> cmpIds = new Set<Id>();
            for (CampaignMember cm : newMap.values()) cmpIds.add(cm.CampaignId);
            
            Map<Id, Campaign> campaigns = new Map<Id, Campaign>([Select Id, Status, FCRM__FCR_Repeat_Responses_Allowed__c From Campaign Where Id IN :cmpIds]);
            
            Set<Id> responsesToRevert = new Set<Id>();
            for (CampaignMember cm : newMap.values()) 
            {
                Campaign cmp = campaigns.get(cm.CampaignId);
                if (cm.HasResponded && oldMap.get(cm.Id).HasResponded && !cmp.FCRM__FCR_Repeat_Responses_Allowed__c || (cmp.FCRM__FCR_Repeat_Responses_Allowed__c && cm.FCRM__FCR_Response_Status__c == 'Not a Response' && cm.status== oldMap.get(cm.id).Status))
                {
                    responsesToRevert.add(cm.Id);   
                }                       
            }
            if (responsesToRevert.size() > 0)
            {
                B_FCRM_ResponseReprocessSupport supportclass = new B_FCRM_ResponseReprocessSupport(eloquaFieldSetMembers, eloquaFields);
                supportclass.revertOrigResponse(responsesToRevert, newMap, oldMap);           
            }           
        }
    }
    
    // Called when response is created by eloqua and HasResponded = false, clear blank fields
    public void clearNonResponses(List<CampaignMember> newcms)
    {
        if (IsRepeatUser)
        {
            List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
            for (CampaignMember cm : newcms) if (!cm.HasResponded) cmsToUpdate.add(cm); 
            
            if (cmsToUpdate.size() > 0)
            {
                B_FCRM_ResponseReprocessSupport supportclass = new B_FCRM_ResponseReprocessSupport(eloquaFieldSetMembers, eloquaFields);                
                supportclass.clearBlankFields(cmsToUpdate);             
            }
        }
    }
    
    public static Boolean clearCreatedResponsesFromUpdateCalled = false;
    
    // Called when response is created by eloqua and HasResponded = false, clear blank fields
    public void clearCreatedResponsesFromUpdate(Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap)
    {       
        if (IsRepeatUser && !clearCreatedResponsesFromUpdateCalled)
        {
            clearCreatedResponsesFromUpdateCalled = true;
            Set<Id> cmsToRevert = new Set<Id>(); 
            Set<Id> cmsToClear = new Set<Id>(); 
            for (CampaignMember cm : newMap.values())
            {
                if (!oldMap.get(cm.Id).HasResponded) 
                {
                	if (cm.HasResponded) cmsToClear.add(cm.Id);
                	else cmsToRevert.add(cm.Id);                	
                }
            }
            B_FCRM_ResponseReprocessSupport supportclass = new B_FCRM_ResponseReprocessSupport(eloquaFieldSetMembers, eloquaFields);
            List<CampaignMember> AllCmsToUpdate = new List<CampaignMember>();
            if (cmsToRevert.size() > 0)
            {
                String query = 'Select ';
                for (Schema.FieldSetMember fsm : eloquaFieldSetMembers) query += fsm.getFieldPath() + ', ';     
                query += ' Status, Id From CampaignMember Where Id IN :cmsToRevert';        
                List<CampaignMember> cmsToUpdate = Database.query(query);     
                Map<Id, CampaignMember> cmsToUpdateMap = new Map<Id, CampaignMember>();
                for (CampaignMember cm : cmsToUpdate) cmsToUpdateMap.put(cm.Id, cm);             
                supportclass.revertOrigResponse(cmsToUpdateMap.keySet(), cmsToUpdateMap, oldMap);                                   
                AllCmsToUpdate.addAll(cmsToUpdateMap.values());                
            }
            if (cmsToClear.size() > 0)
            {
                String query = 'Select ';
                for (Schema.FieldSetMember fsm : eloquaFieldSetMembers) query += fsm.getFieldPath() + ', ';     
                query += ' Status, Id From CampaignMember Where Id IN :cmsToClear';        
                List<CampaignMember> cmsToUpdate = Database.query(query);                                
                supportclass.clearBlankFields(cmsToUpdate);                                   
                AllCmsToUpdate.addAll(cmsToUpdate);            	
            }
            if (AllCmsToUpdate.size() > 0) update AllCmsToUpdate;
        }
    }        

}