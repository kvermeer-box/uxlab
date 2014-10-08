trigger User on User (after delete, after insert, after update, 
before delete, before insert, before update) {
	
	

	if(trigger.isBefore){
		
		if(trigger.isInsert){

			UserTriggerHelper.beforeInsert (Trigger.new);
			
		}else if(trigger.isUpdate){

			UserTriggerHelper.beforeUpdate (Trigger.new, Trigger.oldMap);

		}
		
	}else{
		
		if(trigger.isInsert){

			UserTriggerHelper.afterInsert(Trigger.new);

		}else if(trigger.isUpdate){

			UserTriggerHelper.afterUpdate(Trigger.new, Trigger.oldMap);

		}
	}	

}