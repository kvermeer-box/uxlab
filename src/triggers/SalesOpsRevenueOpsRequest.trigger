/**
 * Trigger for Sales_Ops_Revenue_Ops_Request__c
 *
 * @author Kyle Vermeer 8/22/14
 */
trigger SalesOpsRevenueOpsRequest on Sales_Ops_Revenue_Ops_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    /* Before Insert */
    if (Trigger.isBefore && Trigger.isInsert)
    {
        SalesOpsAndRevOpsRequestTriggerHelper.beforeInsert(Trigger.new);
    }
    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert)
    {
        SalesOpsAndRevOpsRequestTriggerHelper.afterInsert(Trigger.newMap);
    }
    /* Before Update */
    else if (Trigger.isBefore && Trigger.isUpdate)
    {
        SalesOpsAndRevOpsRequestTriggerHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* After Update */
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
        SalesOpsAndRevOpsRequestTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* Before Delete */
    else if (Trigger.isBefore && Trigger.isDelete)
    {
        SalesOpsAndRevOpsRequestTriggerHelper.beforeDelete(Trigger.oldMap);
    }
    /* After Delete */
    else if (Trigger.isAfter && Trigger.isDelete)
    {
        SalesOpsAndRevOpsRequestTriggerHelper.afterDelete(Trigger.oldMap);
    }
    /* After Undelete */
    else if (Trigger.isUnDelete)
    {
        SalesOpsAndRevOpsRequestTriggerHelper.afterUndelete(Trigger.newMap);
    }
}