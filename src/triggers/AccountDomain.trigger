trigger AccountDomain on Account_Domain__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    /* Before Insert */
    if (Trigger.isBefore && Trigger.isInsert)
    {
        AccountDomainTriggerHelper.beforeInsert(Trigger.new);
    }
    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert)
    {
        AccountDomainTriggerHelper.afterInsert(Trigger.newMap);
    }
    /* Before Update */
    else if (Trigger.isBefore && Trigger.isUpdate)
    {
        AccountDomainTriggerHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* After Update */
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
        AccountDomainTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* Before Delete */
    else if (Trigger.isBefore && Trigger.isDelete)
    {
        AccountDomainTriggerHelper.beforeDelete(Trigger.oldMap);
    }
    /* After Delete */
    else if (Trigger.isAfter && Trigger.isDelete)
    {
        AccountDomainTriggerHelper.afterDelete(Trigger.oldMap);
    }
    /* After Undelete */
    else if (Trigger.isUnDelete)
    {
        AccountDomainTriggerHelper.afterUndelete(Trigger.newMap);
    }
}