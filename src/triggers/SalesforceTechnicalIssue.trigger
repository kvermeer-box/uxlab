trigger SalesforceTechnicalIssue on Salesforce_Technical_Issue__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    /* Before Insert */
    if (Trigger.isBefore && Trigger.isInsert)
    {
        SalesforceTechnicalIssueTriggerHelper.beforeInsert(Trigger.new);
    }
    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert)
    {
        SalesforceTechnicalIssueTriggerHelper.afterInsert(Trigger.newMap);
    }
    /* Before Update */
    else if (Trigger.isBefore && Trigger.isUpdate)
    {
        SalesforceTechnicalIssueTriggerHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* After Update */
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
        SalesforceTechnicalIssueTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* Before Delete */
    else if (Trigger.isBefore && Trigger.isDelete)
    {
        SalesforceTechnicalIssueTriggerHelper.beforeDelete(Trigger.oldMap);
    }
    /* After Delete */
    else if (Trigger.isAfter && Trigger.isDelete)
    {
        SalesforceTechnicalIssueTriggerHelper.afterDelete(Trigger.oldMap);
    }
    /* After Undelete */
    else if (Trigger.isUnDelete)
    {
        SalesforceTechnicalIssueTriggerHelper.afterUndelete(Trigger.newMap);
    }
}