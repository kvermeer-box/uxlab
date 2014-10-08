global class Territory_S2AssignLeads {
	
	// Main collections
	private static List<Lead> leads;	
	private static Map<Id, Territory_Stage_2_Assignment_Rule__c> leadsAndRulesMap;
	private static Map<Id, Territory_Employee_Segment_Field_Mapping__c> leadsAndSegmentsMap;
	private static Map<Id, Database.LeadConvertResult> convertedLeadsMap;
	private static Map<Id, SDR_Qualification_Notes__c> leadsAndQualNotesMap;
	private static Map<Id, Routed_Lead__c> leadsAndRoutedLeadsMap;
	private static Map<Id, Lead> originalLeadsMap;
		
	// Helper objects
	private Territory_S2RulesFinder ruleFinder; 
	private Territory_S2RulesDesignator ruleDesignator; 
	private Territory_S2LeadConverter converter;
	
	public Territory_S2AssignLeads(List<Lead> leadz) {
		// Get leads in a map
		leads = Territory_S2LeadsDAO.getLeadsWithQueriedData(leadz);
		
		// Prep everything else 
		prepareCollections();		
	}

	webservice static String routeSingleWebService(String leadId) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Beginning the webservice routing process for lead ' + leadId + '..');		
		String msg;
		
		// Put this lead in a list so we can use it with other functions
		List<Lead> singleLeadList = new List<Lead>();
		Lead lead = new Lead(Id = leadId); 
		singleLeadList.add(lead);
		
		// Mass assign this shit
		Territory_S2AssignLeads leadAssigner = new Territory_S2AssignLeads(singleLeadList);
		try {		
			leadAssigner.massRoute(true);
			msg = generateResultsUrl(leads[0]);
		} catch (Exception e) { 
			msg = e.getMessage();
		}
		 
		return msg;
	}
	
	private static String generateResultsUrl(Lead lead) {				
		User u = [SELECT Id, Name, FullPhotoUrl FROM User WHERE Id = :lead.OwnerId];
		String resultsUrl = '?contact=' + lead.Name + '&contactId=' + convertedLeadsMap.get(lead.Id).getContactId() 
                            + '&account=' + lead.Company + '&accountId=' + convertedLeadsMap.get(lead.Id).getAccountId() 
                            + '&opportunity=' + convertedLeadsMap.get(lead.Id).getOpportunityId() + '&opportunityId=' + convertedLeadsMap.get(lead.Id).getOpportunityId() 
                            + '&baseUrl=' + URL.getSalesforceBaseUrl().toExternalForm() 
                            + '&owner=' + u.Name + '&ownerId=' + u.Id + '&ownerUrl=' + u.FullPhotoUrl
                            + '&territory=' + leadsAndRulesMap.get(lead.Id).Entry_Value__c + '&territoryId=' + leadsAndRulesMap.get(lead.Id).Id
                            + '&segment=' + leadsAndSegmentsMap.get(lead.Id).Name + '&segmentId=' + leadsAndSegmentsMap.get(lead.Id).Id;
    		if (leadsAndQualNotesMap.get(lead.Id) != null) {           
                resultsUrl += '&qualNote=' + leadsAndQualNotesMap.get(lead.Id).Id + '&qualNoteId=' + leadsAndQualNotesMap.get(lead.Id).Id;
			}
                resultsUrl += '&routedLeadId=' + leadsAndRoutedLeadsMap.get(lead.Id).Id;
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Results url is ' + resultsUrl);
        return resultsUrl; 
	}

	public void massRoute(boolean buttonContext) {		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Beginning the mass route juggernaut for ' + leads.size() + ' leads...');
		
		// Mass assign
		Integer sortOrder = 0;
		for (Lead lead : leads) {
			sortOrder++;			
			assign(lead, sortOrder);			
		}
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Beginning the DML process...');
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Current SOQL limit: ' + Limits.getQueries());
		
		// Mass convert		
		converter = new Territory_S2LeadConverter(leads, buttonContext);
		convertedLeadsMap = converter.convertLeads();		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Current SOQL limit after converting leads: ' + Limits.getQueries());
		
		// Make sure this is the real deal
		if (convertedLeadsMap != null && convertedLeadsMap.size() > 0) {
			// Mass update opp members
			List<Opportunity> opps = massUpdateOppMembers(originalLeadsMap.values(), convertedLeadsMap);
			if (opps != null && opps.size() > 0) { update opps; }
			
			// Create qual notes i hate u qual notes
			massCreateSdrQualNotes();
			System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Current SOQL limit after creating qual notes: ' + Limits.getQueries());
			
			// Mass create routed leads
			massCreateRoutedLeads();						
			System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Current SOQL limit after creating routed leads: ' + Limits.getQueries());
		}
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Mass route juggernaut complete. ' + leadsAndRoutedLeadsMap.size() + ' lead(s) routed.');
	}
	
	private void massCreateRoutedLeads() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Mass creating routed leads..');
		
		// Generate
		List<Routed_Lead__c> routedLeads = new List<Routed_Lead__c>();
		for (Lead l : leads) {
			if (convertedLeadsMap.get(l.Id) != null) {
				Routed_Lead__c routedLead = Territory_RoutedLeadFactory.createStage2RoutedLead(l, leadsAndRulesMap.get(l.Id), leadsAndSegmentsMap.get(l.Id), convertedLeadsMap.get(l.Id), leadsAndQualNotesMap.get(l.Id)); 
				if (routedLead != null) {
					routedLeads.add(routedLead);
					leadsAndRoutedLeadsMap.put(l.Id, routedLead);
				}
			}
		}
		
		// Insert
		if (routedLeads != null && routedLeads.size() > 0) {
			insert routedLeads;
		}
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: ' + routedLeads.size() + ' routed leads created.');
	}
	
	private void massCreateSdrQualNotes() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Mass creating sdr qual notes..');
		
		// Generate
		List<SDR_Qualification_Notes__c> sdrQualNotes = new List<SDR_Qualification_Notes__c>();
		for (Lead l : leads) {
			if (convertedLeadsMap.get(l.Id) != null) {			
				SDR_Qualification_Notes__c sdrQualNote = Territory_SdrQualNoteFactory.createSdrQualNote(l, originalLeadsMap.get(l.Id).OwnerId, convertedLeadsMap.get(l.Id).getAccountId());
				if (sdrQualNote != null) {
					sdrQualNotes.add(sdrQualNote);
					leadsAndQualNotesMap.put(l.Id, sdrQualNote);
				}
			}
		}
		
		// Insert
		if (sdrQualNotes != null && sdrQualNotes.size() > 0) {
			insert sdrQualNotes;
		}
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: ' + sdrQualNotes.size() + ' qual notes created.');
	}
	
	private List<Opportunity> massUpdateOppMembers(List<Lead> leadsToParse, Map<Id, Database.LeadConvertResult> leadConverts) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Mass updating opp members..');
		
		List<Opportunity> opps = new List<Opportunity>();
		if (leadsToParse != null && leadConverts != null) {
			for (Lead l : leadsToParse) {				
				Database.LeadConvertResult leadConvert = leadConverts.get(l.Id);
				if (leadConvert != null) {
				
					// Prepare objects for member population					
					User leadOwner = new User(Id = l.OwnerId); 
					leadOwner.UserRole = l.Owner.UserRole;
					Opportunity o = new Opportunity(Id = leadConvert.getOpportunityId());
				
					// Populate
					if (o != null) {
						Opportunity opp = Territory_OpportunityMemberPopulator.associateUserToOpportunityLookupField(leadOwner, o);
						if (opp != null) { opps.add(opp); }
					}
					
				}
			}
		}
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: ' + opps.size() + ' opp members changed.');
		return opps;
	}
	
	private void assign(Lead lead, Integer sortOrder) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Beginning the routing process for lead ' + lead.Id + ' and iteration ' + sortOrder + '...');
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Current SOQL limit: ' + Limits.getQueries());
		
		// Clone the original lead in case we need to reference fields
		originalLeadsMap.put(lead.Id, lead.clone(true));
		
		// Find assignment rule for lead and update mapping
		Territory_Stage_2_Assignment_Rule__c rule = ruleFinder.findAssignmentRule(lead);
		leadsAndRulesMap.put(lead.Id, rule);
		
		// Find owner for lead
		Territory_Employee_Segment_Field_Mapping__c fieldMapping = ruleDesignator.designateOwner(rule, lead);
		leadsAndSegmentsMap.put(lead.Id, fieldMapping);		
		
		// Create a new lead summary and add back to the designator
		ruleDesignator.updateRulesAndLeadSummaryMap(rule, fieldMapping, lead.OwnerId, sortOrder);

		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: All assignment data has been found for lead ' + lead.Id + '.');		
	}

	private void prepareCollections() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2AssignLeads: Preparing collections...');
		
		System.debug('Leadz size: ' + leads.size());
		
		// Helper objects
		ruleFinder     = new Territory_S2RulesFinder(leads);
		ruleDesignator = new Territory_S2RulesDesignator(leads);
		
		// Collections
		leadsAndRulesMap       = new Map<Id, Territory_Stage_2_Assignment_Rule__c>();
		leadsAndSegmentsMap    = new Map<Id, Territory_Employee_Segment_Field_Mapping__c>();
		convertedLeadsMap      = new Map<Id, Database.LeadConvertResult>();
		leadsAndQualNotesMap   = new Map<Id, SDR_Qualification_Notes__c>();
		leadsAndRoutedLeadsMap = new Map<Id, Routed_Lead__c>();
		originalLeadsMap       = new Map<Id, Lead>();
	}
	
}