trigger QuoteApproval on Quote_Approval__c (after update, before delete) {
    /* Before Insert */
    if (Trigger.isBefore && Trigger.isInsert) {
        
    }
    /* After Insert */
    else if (Trigger.isAfter && Trigger.isInsert) {

    }
    /* Before Update */
    else if (Trigger.isBefore && Trigger.isUpdate) {
        
    }
    /* After Update */
    else if (Trigger.isAfter && Trigger.isUpdate) {
        QuoteApproval_TriggerHandler.handleChangedApprovals(Trigger.oldMap, Trigger.newMap);
    }
    /* Before Delete */
    else if (Trigger.isBefore && Trigger.isDelete) {

    }
    /* After Delete */
    else if (Trigger.isAfter && Trigger.isDelete) {

    }
    /* After Undelete */
    else if (Trigger.isUnDelete) {

    }
}