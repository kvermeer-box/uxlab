public class Territory_S2RulesDesignator {

	// Team collections
	private Map<Id, Set<User>> teamAndUserMap;
	
	// Rules collections
	private Map<String, Map<Id, Territory_MaxLeadSummary>> rulesAndLeadSummaryMap;
	
	// Employee segment field mappings
	List<Territory_Employee_Segment_Field_Mapping__c> fieldMappingsSorted;
	
	// Leads
	List<Lead> leads;

	public Territory_S2RulesDesignator(List<Lead> leads) {
		this.leads = leads;
		prepareCollections();	
	}
	
	public void updateRulesAndLeadSummaryMap(Territory_Stage_2_Assignment_Rule__c rule, Territory_Employee_Segment_Field_Mapping__c fieldMapping, Id userId, Integer sortOrder) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Updating the rules and lead summary map for rule ' + rule.Id + ', user ' + userId + ', and sort order ' + sortOrder);
		
		// Create a new summary
		Territory_MaxLeadSummary summary = new Territory_MaxLeadSummary(userId, DateTime.now(), sortOrder);
				
		// Update the master rule and lead summary map
		String ruleAndSegmentId = String.valueOf(rule.Id) + String.valueOf(fieldMapping.Id);
		Map<Id, Territory_MaxLeadSummary> usersAndLeadSummaries = rulesAndLeadSummaryMap.get(ruleAndSegmentId);
		if (usersAndLeadSummaries == null) {
			usersAndLeadSummaries = new Map<Id, Territory_MaxLeadSummary>();
		}		
		usersAndLeadSummaries.put(userId, summary);
		rulesAndLeadSummaryMap.put(ruleAndSegmentId, usersAndLeadSummaries);
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: rules and lead summary map updated for user ' + userId + ' and summary ' + summary.toString());	
	}
 
	public Territory_Employee_Segment_Field_Mapping__c designateOwner(Territory_Stage_2_Assignment_Rule__c rule, Lead lead) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Beginning the owner search for rule ' + rule.Id + ' and lead ' + lead.Name + '...');
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Script limit (before) ' + Limits.getScriptStatements());
		
		Territory_Employee_Segment_Field_Mapping__c fieldMapping;
		Territory_S2RoutingMethod routingMethod = Territory_S2RulesFinder.getLeadRoutingMethod(lead);
		
		// Get employee segment field mapping
		fieldMapping = getEmployeeSegmentFieldMappingForLead(lead);
		
		// Check if it is getting merged into a duplicate contact
		if (routingMethod == Territory_S2RoutingMethod.CONTACT) {
			lead.OwnerId = String.valueOf(Territory_DynamicSoqlUtil.getFieldValueObject(lead, getOwnerFieldFromLeadAndRoutingMethod(lead, routingMethod)));
		} else if (routingMethod == Territory_S2RoutingMethod.ACCOUNT_WITHOUT_REASSIGNMENT) {
			lead.OwnerId = String.valueOf(Territory_DynamicSoqlUtil.getFieldValueObject(lead, getOwnerFieldFromLeadAndRoutingMethod(lead, routingMethod)));
		} else {
			// Check rule assign to fields
			Id assignTo = getAssignToFromRuleAndMapping(rule, fieldMapping);
			
			// Assign the owner 
			lead.OwnerId = assignTo;
			System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Lead will be assigned to ' + assignTo);
		}	
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Script limit (after) ' + Limits.getScriptStatements());
		return fieldMapping;
	}
	
	private Territory_Employee_Segment_Field_Mapping__c getEmployeeSegmentFieldMappingForLead(Lead lead) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Choosing an appropriate employee segment field mapping for lead ' + lead.Name + '...');
		
		Territory_Employee_Segment_Field_Mapping__c fieldMapping;
		Integer employeeSize = Territory_LeadAcctEmployeeSizeCalculator.calculateLeadEmployeeSize(lead);
		if (fieldMappingsSorted != null) {
			// Check to see if it fits the smallest mapping, or null
			if (employeeSize == null || employeeSize <= Integer.valueOf(fieldMappingsSorted[0].Max_Employee_Segment__c)) {
				fieldMapping = fieldMappingsSorted[0];
			// Does not fit smallest mapping, iterate until it does
			} else {
				for (Integer i = 1; i < fieldMappingsSorted.size(); i++) {
					Boolean lastIndex = (i == fieldMappingsSorted.size() - 1);
					// If it's the last index or if it falls within the employee range, winnar
					if (lastIndex || (employeeSize > Integer.valueOf(fieldMappingsSorted[i - 1].Max_Employee_Segment__c) && employeeSize <= Integer.valueOf(fieldMappingsSorted[i].Max_Employee_Segment__c))) {						
						fieldMapping = fieldMappingsSorted[i];
						break;
					}			
				}
			}
		}
		
		// Debug
		String maxEmployeeSegment;
		if (fieldMapping != null) { maxEmployeeSegment = fieldMapping.Max_Employee_Segment__c; }
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Employee segment field mapping max employee segment: ' + maxEmployeeSegment);
		return fieldMapping;
	}
	
	private Id getAssignToFromRuleAndMapping(Territory_Stage_2_Assignment_Rule__c rule, Territory_Employee_Segment_Field_Mapping__c mapping) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Finding owner from rule ' + rule.Id + ' and mapping ' + mapping.Id + '..');
		
		// Check rule assign to fields
		Id assignTo;
		
		// Set defaults
		Id blackHoleAssignToId;
		Territory_Stage_2_Assignment_Rule__c blackHoleRule = Territory_CustomSettings.getS2BlackHoleRule();		
		if (blackHoleRule != null) {
			Object obj = blackHoleRule.get(mapping.Rep_Field_API_Name__c);
			if (obj != null) {
				blackHoleAssignToId = String.valueOf(obj);
			}
		} 
		
		// First see if the rep field is empty
		assignTo = getDesignatedRepId(rule, mapping);
		
		// Next try the team field
		if (assignTo == null) {
			Object teamFieldValue = rule.get(mapping.Team_Field_API_Name__c);
			if (teamFieldValue != null) {
				String ruleAndSegmentId = String.valueOf(rule.Id) + String.valueOf(mapping.Id);
				assignTo = Territory_MaxRoutedLeadSelector.selectDeservingUser(teamAndUserMap.get(String.valueOf(teamFieldValue)), rulesAndLeadSummaryMap.get(ruleAndSegmentId), assignTo); 		
			}
		}
		
		// Finally, default
		if (assignTo == null) {
			String errorMsg = 'Error: \n\nTerritory has not been assigned.\n\nRule: ' + rule.Entry_Value__c + '\nFields: ' + mapping.Rep_Field_API_Name__c + ' and ' + mapping.Team_Field_API_Name__c;
			if (blackHoleRule == null) {
				throw new CustomException(errorMsg);
			} else if (blackHoleAssignToId == null) {
				throw new CustomException(errorMsg);
			} else {
				assignTo = blackHoleAssignToId;
			}						
		}
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Owner will be ' + assignTo);
		return assignTo;
	} 
	
	private String getDesignatedRepId(Territory_Stage_2_Assignment_Rule__c rule, Territory_Employee_Segment_Field_Mapping__c mapping) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Getting designated rep id...');
		
		String repId;
		// First see if the rep field is empty
		Object repFieldValue = rule.get(mapping.Rep_Field_API_Name__c);
		if (repFieldValue != null) {
			// Now check if the user is active
			Boolean userIsActive = assignedUserIsActive(rule, mapping.Rep_Field_API_Name__c);
			if (userIsActive == null || !userIsActive) {
				// If the user isn't active, get the inactive user rule
				Territory_Stage_2_Assignment_Rule__c inactiveUserRule = Territory_CustomSettings.getS2InactiveUserInTerritoryRule();
				Object inactiveUserRuleFieldValue = inactiveUserRule.get(mapping.Rep_Field_API_Name__c);
				if (inactiveUserRuleFieldValue != null) {
					// Check if the inactive user rule user is active
					Boolean inactiveRuleUserIsActive = assignedUserIsActive(inactiveUserRule, mapping.Rep_Field_API_Name__c);
					if (inactiveRuleUserIsActive != null && inactiveRuleUserIsActive) {
						repId = String.valueOf(inactiveUserRule.get(mapping.Rep_Field_API_Name__c));
					}	
				}
			} else {
				repId = String.valueOf(repFieldValue);
			}
		}
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Designated rep id: ' + repId);
		return repId;
	}
	
	private Boolean assignedUserIsActive(Territory_Stage_2_Assignment_Rule__c rule, String userField) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Checking if assigned user is active...');
		
		Boolean isActive = false;
		if (rule != null && userField != null) {
			String isActiveField = userField.replace('__c', '__r') + '.IsActive';
			isActive = Boolean.valueOf(Territory_DynamicSoqlUtil.getFieldValueObject(rule, isActiveField));
		}
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDesignator: Assigned user is active: ' + isActive);
		return isActive;
	}
	
	private void prepareCollections() {
		prepareTeamAndUserMap();
		prepareRulesAndLeadSummaryMap();
		prepareEmployeeSegmentFieldMappings();
	}
	
	private void prepareTeamAndUserMap() {
		System.debug('Territory_S2RulesDesignator: Preparing map of all teams and their users...');
		
		// Get all teams
		Map<Id, Territory_Team__c> allTeamsMap = Territory_TeamDAO.getAllTeamsMap();
		
		// Put all teams in a set
		Set<Territory_Team__c> allTeamsSet = new Set<Territory_Team__c>();
		allTeamsSet.addAll(allTeamsMap.values());		
		
		// Build the map
		teamAndUserMap = Territory_TeamDAO.getTeamAndUserMap(allTeamsSet);
	}
	
	private void prepareRulesAndLeadSummaryMap() {
		System.debug('Territory_S2RulesDesignator: Preparing map of s2 rules and their lead summaries...');
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Script limit (before) ' + Limits.getScriptStatements()); 
		
		// Get all rules in context
		List<Territory_Stage_2_Assignment_Rule__c> rulesList = Territory_S2RulesDAO.getStage2AssignmentRulesForLeads(leads);
		
		// Get these rules in a Set<Id>
		Set<Id> ruleIds = new Set<Id>();
		Map<Id, Territory_Stage_2_Assignment_Rule__c> rulesMap = new Map<Id, Territory_Stage_2_Assignment_Rule__c>();
		rulesMap.putAll(rulesList);
		ruleIds = rulesMap.keySet(); 
		
		// Query
		rulesAndLeadSummaryMap = Territory_RoutedLeadDAO.getRulesAndLeadSummaryMap('Territory_Stage_2_Assignment_Rule__c', ruleIds, new List<String>{'Territory_Employee_Segment_Field_Mapping__c'});
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Script limit (after)' + Limits.getScriptStatements());
	}

	private void prepareEmployeeSegmentFieldMappings() {
		System.debug('Territory_S2RulesDesignator: Preparing all employee field mappings sorted...');
		fieldMappingsSorted = Territory_EmployeeSegmentFieldMappingDAO.getAllMappingsSorted();
	}
	
	public static String getOwnerFieldFromLeadAndRoutingMethod(Lead lead, Territory_S2RoutingMethod routingMethod) {
		System.debug('Territory_S2RulesDesignator: Getting owner field from lead and routing method..');
		
		String ownerField; 
		if (lead != null) {
			if (routingMethod == Territory_S2RoutingMethod.CONTACT) {
				ownerField = 'Territory_Convert_to_Contact__r.Account.Owner.Id';
			} else if (routingMethod == Territory_S2RoutingMethod.ACCOUNT_WITH_REASSIGNMENT) {
				// This shouldn't matter, it is taken from the rule
				ownerField = 'OwnerId';
			} else if (routingMethod == Territory_S2RoutingMethod.ACCOUNT_WITHOUT_REASSIGNMENT) {
				ownerField = 'Territory_Routing_Account__r.Owner.Id';
			}
		}
		System.debug('Territory_S2RulesDesignator: Owner field for routing method ' + routingMethod.name() + ': ' + ownerField);
		return ownerField;
	}
	
}