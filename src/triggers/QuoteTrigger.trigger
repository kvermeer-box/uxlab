trigger QuoteTrigger on zqu__Quote__c (after delete, after insert, after update, 
before delete, before insert, before update) {


	if(trigger.isBefore){
		
		if(trigger.isInsert){
  
			Z_QuoteTriggerHelper.beforeInsert (Trigger.new);
			
		}else if(trigger.isUpdate){

			Z_QuoteTriggerHelper.beforeUpdate (Trigger.new, Trigger.oldMap);

		}else if(trigger.isDelete){

			Z_QuoteTriggerHelper.beforeDelete (Trigger.old);

		}		
	}else{
		
		if(trigger.isUpdate){

			Z_QuoteTriggerHelper.afterUpdate(Trigger.new, Trigger.oldMap);

		}
	}
 
}