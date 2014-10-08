public class Territory_RoutedLeadDAO {

	private static String getMaxSoqlFields(String assignmentObjectName, List<String> additionalGroupings) {
        System.debug(LoggingLevel.ERROR, 'Territory_RoutedLeadDAO: Getting fields to query...');
        
        // Prepare important fields to aggregate query
        List<String> fieldsToAggregate = new List<String>(); 
        fieldsToAggregate.add('CreatedDate');        
        fieldsToAggregate.add('Routed_Lead_Order__c');
        
        // Format fields in dynamic soql readable fashion
        String soqlFields = '';
        for (String field : fieldsToAggregate) {
        	soqlFields += ' MAX(' + field + ') ' + field + ', ';
        }       
        
        // Add fields that don't need to be aggregated
        List<String> fieldsToQuery = new List<String>();
        fieldsToQuery.add(assignmentObjectName);
        if (additionalGroupings != null) {
	        for (String s : additionalGroupings) {
	        	fieldsToQuery.add(s);
	        }
        }
        fieldsToQuery.add('Routed_To__c');
        
        // Format fields that don't need to be aggregated
        soqlFields += String.join(fieldsToQuery, ', ');         
        System.debug(LoggingLevel.ERROR, 'Territory_RoutedLeadDAO: Query max fields: ' + soqlFields);
        
        return soqlFields;
    }

	private static String getSoqlFilters(String assignmentObjectName) {
		// First get everything organized
		List<String> soqlFilters = new List<String>();
		soqlFilters.add(' Undo_Reason__c = null ');
		soqlFilters.add(' Opportunity__r.StageName != \'Dead/No Opp\' ');
		soqlFilters.add(' Routed_To__r.IsActive = true ');
		soqlFilters.add(' Routed_To__r.Remove_From_All_Lead_Assignment_Queues__c = false ');
		soqlFilters.add(' Reassigned_Routed_Lead__c = null ');
		soqlFilters.add(' ' + assignmentObjectName + ' != null ');
		
		String output = ' WHERE ';
		output += String.join(soqlFilters, ' AND ');
		output += ' ';
		return output;
	}
	
	private static String getMaxSoqlQuery(String assignmentObjectName, Set<Id> assignmentObjectSubset, List<String> additionalGroupings) {
		System.debug(LoggingLevel.ERROR, 'Territory_RoutedLeadDAO: Getting base soql query for max soql queries...');
		
		String soql = 'SELECT ' + getMaxSoqlFields(assignmentObjectName, additionalGroupings) 
                    + '     FROM Routed_Lead__c '
                    + ' ' + getSoqlFilters(assignmentObjectName) + ' ';
                    if (assignmentObjectSubset != null) {
                    	soql += ' AND ' + assignmentObjectName + ' IN :assignmentObjectSubset ';
                    }
	          soql += '			AND CreatedDate >= LAST_N_DAYS:' + Territory_CustomSettings.getRoutedLeadHistoryDays().intValue() + ' '
              		+ '		GROUP BY ' + assignmentObjectName + ', ';
              		if (additionalGroupings != null) {
              			soql += String.join(additionalGroupings, ', ') + ', ';
              		}		
              soql += '			Routed_To__c ';  			              		              		
              		
       	System.debug(LoggingLevel.ERROR, 'Territory_RoutedLeadDAO: Base soql query: ' + soql);
       	return soql;       				
	}

    public static Map<String, Map<Id, Territory_MaxLeadSummary>> getRulesAndLeadSummaryMap(String assignmentObjectName, Set<Id> assignmentObjectSubset, List<String> additionalGroupings) {
        System.debug(LoggingLevel.ERROR, 'Territory_RoutedLeadDAO: Getting map of all rules and lead summaries...');
        
        // Initiate collections
        Map<String, Map<Id, Territory_MaxLeadSummary>> rulesAndLeadSummaryMap;
        List<AggregateResult> rulesAndLeadSummaryAggregateResults;        
        
        // Query for aggregate
        String soql = getMaxSoqlQuery(assignmentObjectName, assignmentObjectSubset, additionalGroupings);
        rulesAndLeadSummaryAggregateResults = (List<AggregateResult>)Database.query(soql);
        
        // Parse aggregate data into rules and lead summary map
        rulesAndLeadSummaryMap = parseAggregateResultListIntoRulesAndLeadSummaryMap(assignmentObjectName, additionalGroupings, rulesAndLeadSummaryAggregateResults);        
        System.debug(LoggingLevel.ERROR, 'Territory_RoutedLeadDAO: ' + rulesAndLeadSummaryMap.size() + ' rules mapped.');
        return rulesAndLeadSummaryMap; 
    }
    
    private static Map<String, Map<Id, Territory_MaxLeadSummary>> parseAggregateResultListIntoRulesAndLeadSummaryMap(String assignmentObjectName, List<String> additionalGroupings, List<AggregateResult> rulesAndLeadSummaryAggregateResults) {
    	System.debug(LoggingLevel.ERROR, 'Territory_RoutedLeadDAO: Parsing aggregate result list into rules and lead summary map...');
    	
    	Map<String, Map<Id, Territory_MaxLeadSummary>> rulesAndLeadSummaryMap = new Map<String, Map<Id, Territory_MaxLeadSummary>>();
    	for (AggregateResult agg : rulesAndLeadSummaryAggregateResults) {    		
    		// First, generate the unique key
    		String uniqueId;
    		if (additionalGroupings == null) {
    			uniqueId = String.valueOf(agg.get(assignmentObjectName));
    		} else {
    			uniqueId = String.valueOf(agg.get(assignmentObjectName));
    			for (String s : additionalGroupings) {
    				uniqueId += String.valueOf(agg.get(s));
    			} 
    		}
    		
    		// Now, get the summary map
    		Map<Id, Territory_MaxLeadSummary> userMaxLeadSummary = rulesAndLeadSummaryMap.get(uniqueId);
			if (userMaxLeadSummary == null) {
				userMaxLeadSummary = new Map<Id, Territory_MaxLeadSummary>();
			}    		
			
			// Add a new summary using the user id as a key
			Territory_MaxLeadSummary summary = new Territory_MaxLeadSummary(Id.valueOf(String.valueOf(agg.get('Routed_To__c'))), ((DateTime)agg.get('CreatedDate')), Integer.valueOf(agg.get('Routed_Lead_Order__c'))); 
			userMaxLeadSummary.put(String.valueOf(agg.get('Routed_To__c')), summary);
			System.debug(LoggingLevel.ERROR, 'Territory_RoutedLeadDAO: Max lead summary added to rule ' + uniqueId + '...');
			System.debug(LoggingLevel.ERROR, summary.toString());
			
			// Since java is pass by value, re-add the map to the rule key
			rulesAndLeadSummaryMap.put(uniqueId, userMaxLeadSummary);
    	}
    	return rulesAndLeadSummaryMap;
    }       
    
}