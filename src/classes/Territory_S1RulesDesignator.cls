public class Territory_S1RulesDesignator {
	
	// Team collections
	private Map<Id, Set<User>> teamAndUserMap;
	
	// Rules collections
	private Map<Id, Territory_Stage_1_Assignment_Rule__c> rulesWithTeams;
	private Map<String, Map<Id, Territory_MaxLeadSummary>> rulesAndLeadSummaryMap;

	public Territory_S1RulesDesignator() {
		prepareCollections();
	}
	
	public Lead designateOwner(Territory_Stage_1_Assignment_Rule__c rule, Lead lead) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Choosing an appropriate owner for rule ' + rule.Id + ' and lead ' + lead.Name + '...');
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Script limit (before) ' + Limits.getScriptStatements());
		
		// Check rule assign to fields
		Id assignTo = getAssignToFromRule(rule);
		
		// Assign the owner and undo the assignment bool
		lead.OwnerId = assignTo;
		lead.Trigger_Assignment__c = false;
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Lead will be assigned to ' + assignTo);
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Script limit (after) ' + Limits.getScriptStatements());
		return lead;
	}
	
	public Id getAssignToFromRule(Territory_Stage_1_Assignment_Rule__c rule) {
		// Check rule assign to fields
		Id assignTo;
		if (rule.Assigned_User__c != null) {
			assignTo = rule.Assigned_User__c;
		} else if (rule.Assigned_Queue__c != null) {
			assignTo = rule.Assigned_Queue__c;
		} else if (rule.Assigned_Team__c != null) {
			assignTo = Territory_MaxRoutedLeadSelector.selectDeservingUser(teamAndUserMap.get(rule.Assigned_Team__c), rulesAndLeadSummaryMap.get(rule.Id), Territory_CustomSettings.getS1BlackHoleRule().Assigned_User__c);
		}				
		return assignTo;
	}
	
	public void updateRulesAndLeadSummaryMap(Territory_Stage_1_Assignment_Rule__c rule, Id userId, Integer sortOrder) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Updating the rules and lead summary map for rule ' + rule.Id + ', user ' + userId + ', and sort order ' + sortOrder);
		
		// Create a new summary
		Territory_MaxLeadSummary summary = new Territory_MaxLeadSummary(userId, DateTime.now(), sortOrder);
		
		// Update the master rule and lead summary map
		Map<Id, Territory_MaxLeadSummary> usersAndLeadSummaries = rulesAndLeadSummaryMap.get(rule.Id);
		if (usersAndLeadSummaries == null) {
			usersAndLeadSummaries = new Map<Id, Territory_MaxLeadSummary>();
		} 
		usersAndLeadSummaries.put(userId, summary);
		rulesAndLeadSummaryMap.put(rule.Id, usersAndLeadSummaries);
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: rules and leads summary map updated for user ' + userId + ' and summary ' + summary.toString());
	}
	
	private void prepareCollections() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Preparing collections...');		
		prepareRulesWithTeamsMap();
		prepareTeamAndUserMap();		
		prepareRulesAndLeadSummaryMap();		
	}
	
	private void prepareRulesAndLeadSummaryMap() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Preparing a map of user max lead summaries by rule...');		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Script limit (before) ' + Limits.getScriptStatements());
		rulesAndLeadSummaryMap = Territory_RoutedLeadDAO.getRulesAndLeadSummaryMap('Territory_Stage_1_Assignment_Rule__c', rulesWithTeams.keySet(), null); 
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Script limit (after)' + Limits.getScriptStatements());				
	}
	
	private void prepareTeamAndUserMap() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Preparing a map of all relevant teams and their users...');
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Script limit (before) ' + Limits.getScriptStatements());
		teamAndUserMap = new Map<Id, Set<User>>();
		
		// Get set of all relevant teams
		Set<Territory_Team__c> allRelevantTeams = getAllRelevantTeams();
		
		// Query
		teamAndUserMap = Territory_TeamDAO.getTeamAndUserMap(allRelevantTeams);
	}
	
	private Set<Territory_Team__c> getAllRelevantTeams() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Getting all relevant teams...');
		
		// Set up team related collections
		Set<Territory_Team__c> relevantTeams = new Set<Territory_Team__c>();
		Map<Id, Territory_Team__c> allTeams = Territory_TeamDAO.getAllTeamsMap();

		for (Id id : rulesWithTeams.keySet()) {
			Territory_Team__c team = allTeams.get(rulesWithTeams.get(id).Assigned_Team__c);
			relevantTeams.add(team);
			System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: ' + team.Name + ' added.');
		}

		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Relevant teams size: ' + relevantTeams.size());
		return relevantTeams;
	}
	
	private void prepareRulesWithTeamsMap() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Getting all rules with assigned teams...');
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Script limit (before) ' + Limits.getScriptStatements());
		
		// Set up collections
		rulesWithTeams = new Map<Id, Territory_Stage_1_Assignment_Rule__c>();
		
		// Set up rule related collections
		Map<Id, Territory_Stage_1_Assignment_Rule__c> allRules = Territory_S1RulesDAO.getAllRulesMap();
		
		// Iterate across active rules to find teams that are currently in use
		for (Id id : allRules.keySet()) {
			Territory_Stage_1_Assignment_Rule__c rule = allRules.get(id);
			// Traits of a leaf node w/assigned team
			if (rule.Assigned_Team__c != null && (rule.Child_Rules__c == null || rule.Child_Rules__c == 0)) {
				rulesWithTeams.put(rule.Id, rule);
				System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: ' + rule.Id + ' added.');
			} 
		}
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Rules with teams size: ' + rulesWithTeams.size());
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1RulesDesignator: Script limit (after) ' + Limits.getScriptStatements());
	}

}