trigger Contact on Contact (after delete, after insert, after update, 
before delete, before insert, before update) {

	if(trigger.isBefore){
		
		if(trigger.isInsert){

			ContactTriggerHelper.beforeInsert (Trigger.new);
			
		}else if(trigger.isUpdate){

			ContactTriggerHelper.beforeUpdate (Trigger.newMap, Trigger.oldMap);

		}else if(trigger.isDelete){

			ContactTriggerHelper.beforeDelete(Trigger.oldMap);

		}
		
	}else{
		
		if(trigger.isInsert){

			ContactTriggerHelper.afterInsert(Trigger.newMap);

		}else if(trigger.isUpdate){

			ContactTriggerHelper.afterUpdate(Trigger.newMap, Trigger.oldMap);

		}else if(trigger.isDelete){

			ContactTriggerHelper.afterDelete(Trigger.oldMap);

		}
	}

}