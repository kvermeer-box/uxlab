trigger Opportunity on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    /* Before Insert */
    if (Trigger.isBefore && Trigger.isInsert)
    {
        OpportunityTriggerHelper.beforeInsert(Trigger.new);
    }
    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert)
    {
        OpportunityTriggerHelper.afterInsert(Trigger.newMap);
    }
    /* Before Update */
    else if (Trigger.isBefore && Trigger.isUpdate)
    {
        OpportunityTriggerHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* After Update */
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
        OpportunityTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* Before Delete */
    else if (Trigger.isBefore && Trigger.isDelete)
    {
        OpportunityTriggerHelper.beforeDelete(Trigger.oldMap);
    }
    /* After Delete */
    else if (Trigger.isAfter && Trigger.isDelete)
    {
        OpportunityTriggerHelper.afterDelete(Trigger.oldMap);
    }
    /* After Undelete */
    else if (Trigger.isUnDelete)
    {
        OpportunityTriggerHelper.afterUndelete(Trigger.newMap);
    }
}