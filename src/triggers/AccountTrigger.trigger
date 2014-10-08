trigger AccountTrigger on Account (after insert, after update, after delete, before insert, 
before update, before delete) {


	if(trigger.isBefore){
		
		if(trigger.isInsert){

			AccountTriggerHelper.beforeInsert (Trigger.new);
			
		}else if(trigger.isUpdate){

			AccountTriggerHelper.beforeUpdate (Trigger.new, Trigger.oldMap);

		}
		
	}else{
		
		if(trigger.isInsert){

			AccountTriggerHelper.afterInsert(Trigger.new);

		}else if(trigger.isUpdate){

			AccountTriggerHelper.afterUpdate(Trigger.new, Trigger.oldMap);

		}
	}

}