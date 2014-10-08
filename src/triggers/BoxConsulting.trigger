trigger BoxConsulting on Box_Consulting__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    /* Before Insert */
    if (Trigger.isBefore && Trigger.isInsert)
    {
        BoxConsultingTriggerHelper.beforeInsert(Trigger.new);
    }
    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert)
    {
        BoxConsultingTriggerHelper.afterInsert(Trigger.newMap);
    }
    /* Before Update */
    else if (Trigger.isBefore && Trigger.isUpdate)
    {
        BoxConsultingTriggerHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* After Update */
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
        BoxConsultingTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    /* Before Delete */
    else if (Trigger.isBefore && Trigger.isDelete)
    {
        BoxConsultingTriggerHelper.beforeDelete(Trigger.oldMap);
    }
    /* After Delete */
    else if (Trigger.isAfter && Trigger.isDelete)
    {
        BoxConsultingTriggerHelper.afterDelete(Trigger.oldMap);
    }
    /* After Undelete */
    else if (Trigger.isUnDelete)
    {
        BoxConsultingTriggerHelper.afterUndelete(Trigger.newMap);
    }
}