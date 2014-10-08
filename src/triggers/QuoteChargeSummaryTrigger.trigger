trigger QuoteChargeSummaryTrigger on zqu__QuoteChargeSummary__c (after delete, after insert, after update, 
before delete, before insert, before update) {

    if(trigger.isBefore){
  
        if(trigger.isInsert){

            Z_QuoteChargeSummaryTriggerHelper.beforeInsert (Trigger.new);

        }else if(trigger.isUpdate){

            Z_QuoteChargeSummaryTriggerHelper.beforeUpdate (Trigger.new, Trigger.oldMap);

        }else if(trigger.isDelete){

            //Z_QuoteChargeSummaryTriggerHelper.beforeDelete (Trigger.old);  

        }
    }else{

        if(trigger.isInsert){

            //Z_QuoteChargeSummaryTriggerHelper.afterInsert(Trigger.new);

        }else if(trigger.isUpdate){

            //Z_QuoteChargeSummaryTriggerHelper.afterUpdate(Trigger.new, Trigger.oldMap);

        }else if(trigger.isDelete){

            //Z_QuoteChargeSummaryTriggerHelper.afterDelete (Trigger.old);
        }

    }



}