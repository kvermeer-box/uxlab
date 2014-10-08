public class Territory_S2RulesFinder {

	private Map<String, Territory_Stage_2_Assignment_Rule__c> s2RulesEntryValueMapAllCaps;
	private final String ENTRY_VALUE_BLACK_HOLE                 = '<< BLACK HOLE >>';
	private final String ENTRY_VALUE_DUPE_CONTACT               = '<< DUPLICATE CONTACT >>';
	private final String ENTRY_VALUE_NO_REASSIGNMENT_ACCOUNT    = '<< NO REASSIGNMENT >>';
	private final String ENTRY_VALUE_INACTIVE_USER_IN_TERRITORY = '<< INACTIVE USER IN TERRITORY >>';
	
	private List<Lead> leads;
	
	public Territory_S2RulesFinder(List<Lead> leads) {
		this.leads = leads; 
		
		// Set up collections
		s2RulesEntryValueMapAllCaps = Territory_S2RulesDAO.getStage2AssignmentRulesKeyValueMapAllCapsForLeads(leads);
		
		// Set up custom settings for future use
		Territory_CustomSettings.setS2BlackHoleRule(s2RulesEntryValueMapAllCaps.get(ENTRY_VALUE_BLACK_HOLE));
		Territory_CustomSettings.setS2DuplicateContactRule(s2RulesEntryValueMapAllCaps.get(ENTRY_VALUE_DUPE_CONTACT));	
		Territory_CustomSettings.setS2NoReassignmentAccountRule(s2RulesEntryValueMapAllCaps.get(ENTRY_VALUE_NO_REASSIGNMENT_ACCOUNT));
		Territory_CustomSettings.setS2InactiveUserInTerritoryRule(s2RulesEntryValueMapAllCaps.get(ENTRY_VALUE_INACTIVE_USER_IN_TERRITORY));
	}
	
	public static Set<String> getLeadFieldsForFindingRules() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesFinder: Getting fields required for lead conversion..');
		
		Set<String> fieldsForConversion = new Set<String>();		
		fieldsForConversion.add('Territory_Routing_Account__r.Id');
		fieldsForConversion.add('Territory_Routing_Account__r.Owner.UserRole.Name');
		
		return fieldsForConversion;
	} 
	
	public Territory_Stage_2_Assignment_Rule__c findAssignmentRule(Lead lead) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesFinder: Finding assignment rule for lead ' + lead.Id + '..');

		Territory_Stage_2_Assignment_Rule__c rule;

		// Get routing method
		Territory_S2RoutingMethod routingMethod = getLeadRoutingMethod(lead);
		
		// Get rule
		if (routingMethod == Territory_S2RoutingMethod.CONTACT) {
			rule = Territory_CustomSettings.getS2DuplicateContactRule();
		} else if (routingMethod == Territory_S2RoutingMethod.ACCOUNT_WITHOUT_REASSIGNMENT) {
			rule = Territory_CustomSettings.getS2NoReassignmentAccountRule();
		} else { 
			rule = getBestAssignmentRule(lead);
		}

		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesFinder: Assignment rule: ' + rule.Id + '..');
		return rule;
	}
	
	private Territory_Stage_2_Assignment_Rule__c getBestAssignmentRule(Lead lead) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesFinder: Getting best lead assignment rule..');
		 
		// Iterate across possible lead entry methods until a rule is found.
		Territory_Stage_2_Assignment_Rule__c rule;
		List<Territory_EntryValueField> leadEntryValueFields = Territory_S2LeadsDAO.getEntryValueFieldsByPriority();
		for (Territory_EntryValueField field : leadEntryValueFields) {
			// Get entry value for the particular entry field
			String value = Territory_EntryValueFieldUtils.getEntryValue(lead, field);
			if (value != null) {
				// Try to find a rule, if no rule exists, we move on to the next entry field
				rule = s2RulesEntryValueMapAllCaps.get(value.toUpperCase());
				if (rule != null) {
					break;
				}
			}
		}
		
		// If there is no matching rule, honor the default
		if (rule == null) {						
			Territory_Stage_2_Assignment_Rule__c defaultRule = Territory_CustomSettings.getS2BlackHoleRule();
			if (defaultRule == null) {
				throw new CustomException('Error: Route Me button cannot be used on this lead. There is no matching country or zip code territory.');
			} else {			
				rule = defaultRule;
			}
		}
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesFinder: Best lead assignment rule: ' + rule.Id);
		return rule;
	}
	
	public static Territory_S2RoutingMethod getLeadRoutingMethod(Lead lead) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesFinder: Getting lead routing method..');
		
		Territory_S2RoutingMethod routingMethod;
		if (lead.Territory_Convert_to_Contact__c != null) {
			if (lead.Territory_Routing_Account__c != null || lead.Territory_Convert_to_Account__c != null) {
				throw new CustomException('Error: Please select either:\n1. A "Routing Account" and "Convert to Account," or\n2. A "Convert to Contact."');
			} else {
				routingMethod = Territory_S2RoutingMethod.CONTACT;
			}
		} else {
			if (lead.Territory_Routing_Account__c == null || lead.Territory_Convert_to_Account__c == null) {
				throw new CustomException('Error: Please select either:\n1. A "Routing Account" and "Convert to Account," or\n2. A "Convert to Contact."');
			} else {
			if (lead.Territory_Do_Not_Assign_to_Territory__c == null || !lead.Territory_Do_Not_Assign_to_Territory__c) {
					routingMethod = Territory_S2RoutingMethod.ACCOUNT_WITH_REASSIGNMENT;
				} else {
					routingMethod = Territory_S2RoutingMethod.ACCOUNT_WITHOUT_REASSIGNMENT;
				}
			}
		}
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesFinder: Lead routing method: ' + routingMethod);
		return routingMethod;
	}
	
	/*
	private static boolean isRepOwnedRoutingAccount(Lead lead) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesFinder: Checking if lead\'s routing account is rep owned..');
		
		boolean isRepOwned = false;
		if (lead.Territory_Routing_Account__c != null) {
			Set<String> repRoles = Territory_CustomSettings.getSalesRepRoleNames();
			for (String repRole : repRoles) {
				if (lead.Territory_Routing_Account__r.Owner.UserRole.Name.toLowerCase().contains(repRole.toLowerCase())) {
					isRepOwned = true;
					break;	
				}
			}
		} 
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesFinder: Lead\'s routing account is rep owned: ' + isRepOwned);
		return isRepOwned;
	}
	*/

}