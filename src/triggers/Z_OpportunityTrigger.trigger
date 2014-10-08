trigger Z_OpportunityTrigger on Opportunity (after delete, after insert, after update, 
before delete, before insert, before update) {

	if(trigger.isBefore){
		
		if(trigger.isUpdate){

			Z_OpportunityTriggerHelper.beforeUpdate (Trigger.new, Trigger.oldMap);
		}
		
	} else if(trigger.isAfter){
		
		if(trigger.isUpdate){

			Z_OpportunityTriggerHelper.afterUpdate (Trigger.new, Trigger.oldMap);
		}
		
	}
}