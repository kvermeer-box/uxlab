trigger SalesRequest on Sales_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    /* Before Insert */
    if (Trigger.isBefore && Trigger.isInsert)
    {
        SalesRequestTriggerHelper.beforeInsert(Trigger.new);
    }
    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert)
    {
        SalesRequestTriggerHelper.afterInsert(Trigger.newMap);
    }
    /* Before Update */
    else if (Trigger.isBefore && Trigger.isUpdate)
    {
        SalesRequestTriggerHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* After Update */
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
        SalesRequestTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* Before Delete */
    else if (Trigger.isBefore && Trigger.isDelete)
    {
        SalesRequestTriggerHelper.beforeDelete(Trigger.oldMap);
    }
    /* After Delete */
    else if (Trigger.isAfter && Trigger.isDelete)
    {
        SalesRequestTriggerHelper.afterDelete(Trigger.oldMap);
    }
    /* After Undelete */
    else if (Trigger.isUnDelete)
    {
        SalesRequestTriggerHelper.afterUndelete(Trigger.newMap);
    }
}