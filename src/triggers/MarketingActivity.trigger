trigger MarketingActivity on Marketing_Activity__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    /* Before Insert */
    if (Trigger.isBefore && Trigger.isInsert)
    {
        MarketingActivityTriggerHelper.beforeInsert(Trigger.new);
    }
    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert)
    {
        MarketingActivityTriggerHelper.afterInsert(Trigger.newMap);
    }
    /* Before Update */
    else if (Trigger.isBefore && Trigger.isUpdate)
    {
        MarketingActivityTriggerHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* After Update */
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
        MarketingActivityTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* Before Delete */
    else if (Trigger.isBefore && Trigger.isDelete)
    {
        MarketingActivityTriggerHelper.beforeDelete(Trigger.oldMap);
    }
    /* After Delete */
    else if (Trigger.isAfter && Trigger.isDelete)
    {
        MarketingActivityTriggerHelper.afterDelete(Trigger.oldMap);
    }
    /* After Undelete */
    else if (Trigger.isUnDelete)
    {
        MarketingActivityTriggerHelper.afterUndelete(Trigger.newMap);
    }
}