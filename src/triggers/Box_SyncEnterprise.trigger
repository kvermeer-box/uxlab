trigger Box_SyncEnterprise on Tenant__c (after insert, after update) {

	static final PRM_Settings__c settings           = PRM_Settings__c.getInstance('default');
	static final Boolean AUTO_PROVISION_ENTERPRISES = settings == null ? false : settings.Automatically_Provision_Enterprises__c;
	static final Boolean AUTO_UPDATE_ENTERPRISES    = settings == null ? false : settings.Automatically_Update_Enterprises__c;

	static integer iteration = 0;
	System.debug('Box_SyncEnterprise iteration: ' + iteration);	
	
	if (iteration > 0) {
		System.debug('Box_SyncEnterprise iteration: ' + iteration + '. Skipping trigger...');
	} else if (ContextControl.isFuture) {
		System.debug('Box_SyncEnterprise is getting called from a future method. Skipping trigger...');
	} else if (ContextControl.isBatch) {
		System.debug('Box_SyncEnterprise is getting called from a batch method. Skipping trigger...');	
	} else if (ContextControl.preventLooping) {
		System.debug('Box_SyncEnterprise is looping. Skipping trigger...');
	} else {
		iteration++;
		if (Trigger.size == 1) {
			// Provisioning flow
			if (Trigger.isInsert) {
				if (AUTO_PROVISION_ENTERPRISES) {
					// Call the "Create" enterprise API on each tenant
					for (Tenant__c t : Trigger.new) {
						Box_SyncingEnterprise.futureCreate(t.id);
					}
				} else {
					System.debug('Automatically Provision Enterprises setting is off in PRM Settings. Not provisioning...');
				}
			// Update flow
			} else if (Trigger.isUpdate) {
				if (AUTO_UPDATE_ENTERPRISES) {
					// Call the "Edit" enterprise API on each tenant
					for (Tenant__c t : Trigger.new) {
						Box_SyncingEnterprise.futureEdit(t.id);
					}
				} else {
					System.debug('Automatically Update Enterprises setting is off in PRM Settings. Not syncing...');
				}
			}
		} else {
			System.debug('This is a mass import/update batch. Objects will not be synced to Box.');
		}
	}


}