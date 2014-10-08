trigger QuotaUploadTrigger on Quota_Upload__c (after insert, after update, before insert, 
before update) {


	if(trigger.isBefore){
		
		if(trigger.isInsert){

			QuotaUploadTriggerHelper.beforeInsert (Trigger.new);
			
		}else if(trigger.isUpdate){

			QuotaUploadTriggerHelper.beforeUpdate (Trigger.new, Trigger.oldMap);

		}
		
	} 

}