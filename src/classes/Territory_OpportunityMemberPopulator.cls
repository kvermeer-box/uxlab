public class Territory_OpportunityMemberPopulator {

	private static Map<String, String> getRoleToFieldMap() {
		Map<String, String> roleToFieldMap = new Map<String, String>();
		roleToFieldMap.put('SDR', 'SDR_Lookup__c');
		return roleToFieldMap;
	}

	public static Opportunity associateUserToOpportunityLookupField(User u, Opportunity o) {
		System.debug(LoggingLevel.ERROR, 'Territory_OpportunityMemberPopulator: Associating user to opportunity lookup field...');
		
		Opportunity updatedOpp;
		if (u != null && o != null) {
			if (u.UserRole != null) {				
				// Get map of relevant roles/fields
				Map<String, String> roleToFieldMap = getRoleToFieldMap();
								
				// Iterate across map to find a match
				for (String s : roleToFieldMap.keySet()) {										
					if (u.UserRole.Name.contains(s)) {						
						// Update the relevant field
						String field = roleToFieldMap.get(s);
						o.put(field, u.Id);
						updatedOpp = o;
						System.debug(LoggingLevel.ERROR, 'Territory_OpportunityMemberPopulator: Opportunity field ' + field + ' populated with user ' + u);
						break;
					}
				}
			}
		}
		
		return updatedOpp;
	}

	public static Set<String> getFieldsForOppMemberPopulator() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_OpportunityMemberPopulator: Getting fields required for populating opportunity members..');
		
		Set<String> objectFields = new Set<String>();
		objectFields.add('Owner.UserRole.Id');
		objectFields.add('Owner.UserRole.Name');
		
		return objectFields;
	}

}