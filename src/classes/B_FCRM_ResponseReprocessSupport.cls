public class B_FCRM_ResponseReprocessSupport {
    
    public List<Schema.FieldSetMember> eloquaFieldSetMembers {get;set;}
    
    public Set<String> eloquaFields {get;set;}
    
    // Constructor sets eloqua field related properties 
    public B_FCRM_ResponseReprocessSupport(List<Schema.FieldSetMember> fieldSetMembers, Set<String> fieldsSet)
    {
        eloquaFieldSetMembers = fieldSetMembers;
        eloquaFields = fieldsSet;
    }
    
    // Set Eloqua field values on repeat response equal to new field values of the originating response.
    // Then revert originating response's Eloqua field values back to old values.  
    public void setOrigFieldValuesOnRepeatAndRevertOrig(Map<Id, CampaignMember> repeatResponseByOrigCmId, Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap)
    {
        for (Id origCmId : repeatResponseByOrigCmId.keySet())
        {
            CampaignMember repeatResponse = repeatResponseByOrigCmId.get(origCmId);
            CampaignMember origResponseNew = newMap.get(origCmId);
            CampaignMember origResponseOld = oldMap.get(origCmId);
            
            // Clears blanks on originating response
            clearBlankFields(new List<CampaignMember>{origResponseNew});
            
            // Merge new values on repeat response
            mergeEloquaValues(repeatResponse, origResponseNew);
            
            // Revert originating response's Eloqua fields to old values  
            mergeEloquaValues(origResponseNew, origResponseOld);
        }
    }
    
    // Reverts originating response's Eloqua field values back to its old values.
    public void revertOrigResponse(Set<Id> responsesToRevert, Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap) 
    {
        for (Id cmId : responsesToRevert) mergeEloquaValues(newMap.get(cmId), oldMap.get(cmId)); 
    }

    // Eloqua cannot set fields null so instead sets fields with value containing "BLANK"
    public void clearBlankFields(List<CampaignMember> cmsToUpdate)
    {
        for (CampaignMember cm : cmsToUpdate)
        {
            for (Schema.FieldSetMember fsm : eloquaFieldSetMembers)
            {
                if (eloquaFields.contains(fsm.getFieldPath()) && isBlankEloquaCustomField(fsm, cm))
                {
                    cm.put(fsm.getFieldPath(), null);
                }
            }
        }
    }
    
    // Merges Eloqua field values from "fromCm" to "toCm"
    public void mergeEloquaValues(CampaignMember toCm, CampaignMember fromCm)
    {
        for (String field : eloquaFields) if (field != null) toCm.put(field, fromCm.get(field));
    }
    
    // Returns Boolean indicating whether Eloqua field is set to "Blank" 
    public static Boolean isBlankEloquaCustomField(Schema.FieldSetMember fieldSetMember, CampaignMember cm)
    {
        Schema.DisplayType fieldDisplayType = fieldSetMember.getType();
        
        if (fieldDisplayType == DisplayType.MULTIPICKLIST 
            || fieldDisplayType == DisplayType.PICKLIST 
            || fieldDisplayType == DisplayType.STRING 
            || fieldDisplayType == DisplayType.TEXTAREA)
        {
            String fieldVal = (String)cm.get(fieldSetMember.getFieldPath());
            if (fieldVal != null) return fieldVal.toLowerCase().contains('blank');
        }   
        else if (fieldDisplayType == DisplayType.URL )
        {
            String fieldVal = (String)cm.get(fieldSetMember.getFieldPath());
            if (fieldVal != null) return fieldVal.toLowerCase().contains('www.blank.com');        	
        }    
        return false;
    }

}