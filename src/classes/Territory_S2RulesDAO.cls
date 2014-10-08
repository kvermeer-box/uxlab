public class Territory_S2RulesDAO {

	private static List<Territory_Stage_2_Assignment_Rule__c> s2RulesInContext;
	private static Map<String, Territory_Stage_2_Assignment_Rule__c> s2RulesKeyValueMapAllCaps;

	public static String getSoqlFields() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: Getting fields to query...');
        
        // Prepare base fields to query
        List<String> fieldsToQueryList = new List<String>(); 
        Set<String> fieldsToQuery = new Set<String>(); 
        fieldsToQuery.add('Id');
        fieldsToQuery.add('Active__c');
        fieldsToQuery.add('Corporate_Rep__c');
        fieldsToQuery.add('Corporate_Rep__r.IsActive');
        fieldsToQuery.add('Country__c');
        fieldsToQuery.add('Entry_Value__c');
        fieldsToQuery.add('ESB_Rep__c');
        fieldsToQuery.add('ESB_Rep__r.IsActive');
        fieldsToQuery.add('Major_Rep__c');
        fieldsToQuery.add('Major_Rep__r.IsActive');
        fieldsToQuery.add('National_Rep__c');
        fieldsToQuery.add('National_Rep__r.IsActive');
        fieldsToQuery.add('Zip_Code__c');  
        
        // Add rep/team fields as designated in the Territory_EmployeeSegmentFieldMapping objects
        fieldsToQuery.addAll(Territory_EmployeeSegmentFieldMappingDAO.getFieldsToQuery(Territory_EmployeeSegmentFieldMappingDAO.getRepFieldApiName()));
        fieldsToQuery.addAll(Territory_EmployeeSegmentFieldMappingDAO.getFieldsToQuery(Territory_EmployeeSegmentFieldMappingDAO.getTeamFieldApiName()));
        
        // Format fields in dynamic soql readable fashion
        fieldsToQueryList.addAll(fieldsToQuery);
        String soqlFields = String.join(fieldsToQueryList, ', ');       
        System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: Query fields: ' + soqlFields);
        
        return soqlFields;
    }
    
    public static String getBaseSoqlQuery(Set<String> entryValueSubset) {
        System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: Getting base soql query for s2 assignment rules...');
        
        String soql = 'SELECT ' + getSoqlFields()
                    + '     FROM Territory_Stage_2_Assignment_Rule__c '
                    + '     WHERE Active__c = true '; 
                   if (entryValueSubset != null) {
                   		soql += ' AND (Entry_Value__c IN :entryValueSubset '
                   			 // This gets default rules
                   			 +  ' OR Entry_Value__c LIKE \'%<<%\') ';
                   }
                               
        System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: Base soql query: ' + soql);
        return soql;
    }
    
    public static List<Territory_Stage_2_Assignment_Rule__c> getStage2AssignmentRulesForLeads(List<Lead> leads) {    
    	if (s2RulesInContext == null) {
    		s2RulesInContext = getStage2AssignmentRules(getEntryValueSet(leads));
    	}    		
    	return s2RulesInContext;
    }
    
    public static Map<String, Territory_Stage_2_Assignment_Rule__c> getStage2AssignmentRulesKeyValueMapAllCapsForLeads(List<Lead> leads) {    
    	if (s2RulesKeyValueMapAllCaps == null) {
    		s2RulesKeyValueMapAllCaps = getStage2AssignmentRulesKeyValueMapAllCaps(getEntryValueSet(leads));
    	}    		
    	return s2RulesKeyValueMapAllCaps;
    }

	private static List<Territory_Stage_2_Assignment_Rule__c> getStage2AssignmentRules(Set<String> entryValueSubset) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: Getting list of s1 assignment rules...');
        
        if (s2RulesInContext == null) {
	        String soql = getBaseSoqlQuery(entryValueSubset);
	        s2RulesInContext = (List<Territory_Stage_2_Assignment_Rule__c>)Database.query(soql);
	        System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: ' + s2RulesInContext.size() + ' rules queried.');
        }
        
        return s2RulesInContext; 
	}
	
	private static Map<String, Territory_Stage_2_Assignment_Rule__c> getStage2AssignmentRulesKeyValueMapAllCaps(Set<String> entryValueSubset) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: Getting map of s1 assignment rules by entry method...');
		
		if (s2RulesKeyValueMapAllCaps == null) {
			s2RulesKeyValueMapAllCaps = new Map<String, Territory_Stage_2_Assignment_Rule__c>();
			List<Territory_Stage_2_Assignment_Rule__c> rulesList = getStage2AssignmentRules(entryValueSubset);
			for (Territory_Stage_2_Assignment_Rule__c rule : rulesList) {
				s2RulesKeyValueMapAllCaps.put(rule.Entry_Value__c.toUppercase(), rule);
			}
			System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: ' + s2RulesKeyValueMapAllCaps.size() + ' rules mapped.');
		}
		return s2RulesKeyValueMapAllCaps;
	}
	
	private static Set<String> getEntryValueSet(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: Creating set of entry values..');
		
		Set<String> entryValueSet = new Set<String>();
		List<Territory_EntryValueField> leadEntryValueFields = Territory_S2LeadsDAO.getEntryValueFieldsByPriority(); 
		for (Lead lead : leads) {
			for (Territory_EntryValueField field : leadEntryValueFields) {
				if (Territory_EntryValueFieldUtils.getEntryValue(lead, field) != null) { entryValueSet.add(Territory_EntryValueFieldUtils.getEntryValue(lead, field)); }
				// if (lead.get(field.fieldName) != null) { entryValueSet.add(Territory_EntryValueFieldUtils.getEntryValue(lead, field)); } 
			}
		}
		
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2RulesDAO: Entry values - ' + String.valueOf(entryValueSet));
		return entryValueSet;
	}

}