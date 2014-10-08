trigger CampaignMemberTrigger on CampaignMember (before update, before insert, after update) {

    B_FCRM_ResponseReprocessPlugin plugin = new B_FCRM_ResponseReprocessPlugin();
                    
    if (trigger.isBefore)
    {          
        CampaignMemberSetFirstOwnerRole.setFirstOwnerRoleRequestHandler(trigger.new, trigger.oldMap, trigger.isInsert);
          
        if (trigger.isUpdate)
        {       
            plugin.revertToOrigResponseOnNoRepeat(trigger.newMap, trigger.oldMap);
        }        
        else if (trigger.isInsert)
        {
            plugin.clearNonResponses(trigger.new);
        }           
    }
    
    if (trigger.isAfter && trigger.isUpdate)
    {
        plugin.clearCreatedResponsesFromUpdate(trigger.newMap, trigger.oldMap);
    }       

}