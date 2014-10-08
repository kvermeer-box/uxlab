trigger QuoteRatePlanCharge on zqu__QuoteRatePlanCharge__c (after delete, after insert, after update, 
before delete, before insert, before update) {

    if(trigger.isBefore){

        if(trigger.isInsert){

            Z_QuoteRatePlanChargeTriggerHelper.beforeInsert (Trigger.new);

        }else if(trigger.isUpdate){

            Z_QuoteRatePlanChargeTriggerHelper.beforeUpdate (Trigger.new, Trigger.oldMap);

        } 
    } 


}