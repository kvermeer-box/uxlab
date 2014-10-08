trigger insertLeadOwnerRole on Lead (before insert, before update) {
	
	static Integer iteration = 0;
	
	if (iteration == 0) {
		System.debug('insertLeadOwnerRole iteration: ' + iteration + '. Script limit: ' + Limits.getScriptStatements());
		System.debug('insertLeadOwnerRole cumulative query rows: ' + Limits.getQueryRows());
		iteration++;
		List<User> usersList = [SELECT Id, UserRoleId, UserRole.Name FROM User WHERE isActive = true AND (NOT Profile.Name LIKE '%Eventforce%') AND (NOT Profile.Name LIKE '%Chatter%')];
		Map<Id, User> users = new Map<Id, User>();
		users.putAll(usersList);
		
		for (Lead l : trigger.new) {
			if (l.OwnerId == null) {
				continue;
			}
			Boolean isChanged = false;
			if (Trigger.isInsert && l.OwnerId != null) {
				isChanged = true;
			} else {
				String oldOwner = Trigger.oldMap.get(l.Id).OwnerId;
				String newOwner = Trigger.newMap.get(l.Id).OwnerId;
				if (oldOwner == null || (newOwner != null && !oldOwner.equals(newOwner))) {
					isChanged = true;
				}
			}
			if (isChanged && l.OwnerId != null) {
				User u = users.get(l.OwnerId);
				if (u != null && u.UserRole != null && u.UserRole.Name != null && !Test.isRunningTest()) {
					l.Owner_Role__c = u.UserRole.Name;
					if (l.Owner_Role__c != null && (l.Owner_Role__c.contains('OBR') || l.Owner_Role__c.contains('Outbound Business Rep'))) {
						l.RecordTypeId = '012600000009V9b';	
					}					
					System.debug('New owner role for lead ' + l.Name + ': ' + l.Owner_Role__c);
				}
				break;
			}
		}
	}
	
}