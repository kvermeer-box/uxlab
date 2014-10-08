public class Territory_S1AssignLeads {

	// Context variables
	private List<Lead> leads;
	private List<Routed_Lead__c> routedLeads;
	
	// Helper objects
	private Territory_S1RulesFinder ruleFinder; 
	private Territory_S1RulesDesignator ruleDesignator; 
	
	public Territory_S1AssignLeads(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Initial script limit ' + + Limits.getScriptStatements());
		
		// Initialize collections
		this.leads = leads;
		this.routedLeads = new List<Routed_Lead__c>();
		
		// Initialize helper objects
		this.ruleFinder = new Territory_S1RulesFinder();
		this.ruleDesignator = new Territory_S1RulesDesignator();
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Script limit after setup: ' + + Limits.getScriptStatements());
	}

	public void massAssign() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Assigning ' + leads.size() + ' leads...');
		Integer sortOrder = 0;		
		for (Lead lead : leads) {
			sortOrder++;
			System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Iteration ' + sortOrder);
			assign(lead, sortOrder);
		}
		
		// Commit changes to DB
		update leads;
		insert routedLeads;		
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: ' + leads.size() + ' leads assigned and ' + routedLeads.size() + ' routed leads created.');
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Final script statements count: ' + Limits.getScriptStatements());
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Final query count: ' + Limits.getQueries());
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Final query row count: ' + Limits.getQueryRows());
	}
	
	private void assign(Lead lead, Integer sortOrder) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Assign lead ' + lead.Id);

		// Find assignment rule for lead
		Territory_Stage_1_Assignment_Rule__c rule = ruleFinder.findAssignmentRule(lead);		

		// Assign the lead (do not update)		
		ruleDesignator.designateOwner(rule, lead);
		
		// Just in case...
		if (lead.OwnerId == null) {
			System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Lead has no owner! Assigning to black hole...');
			rule = Territory_CustomSettings.getS1BlackHoleRule();
			lead.OwnerId = ruleDesignator.getAssignToFromRule(Territory_CustomSettings.getS1BlackHoleRule());
		}
		
		// Create a routed lead and assign to appropriate list
		Routed_Lead__c routedLead = Territory_RoutedLeadFactory.createStage1RoutedLead(lead, rule);
		routedLeads.add(routedLead);
		
		// Create a new lead summary and add back to the designator
		ruleDesignator.updateRulesAndLeadSummaryMap(rule, lead.OwnerId, sortOrder);
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads: Assignment process complete for lead ' + lead.Id);
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads:     Rule - ' + rule.Id);
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads:     Owner - ' + lead.OwnerId);
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1AssignLeads:     Routed Lead - TBA...');
	}

}