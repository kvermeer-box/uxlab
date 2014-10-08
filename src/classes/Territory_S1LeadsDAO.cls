public class Territory_S1LeadsDAO {
	
	private static Set<String> leadIds;
	
	private static Set<String> getSoqlFieldSet() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1LeadsDAO: Getting set of fields to query...');
		
		// Base lead fields	
		Set<String> fieldsToQuery = new Set<String>();
		fieldsToQuery.add('CleanCM__c');
		fieldsToQuery.add('Email');
		fieldsToQuery.add('Id');
		fieldsToQuery.add('Name');
		fieldsToQuery.add('Partner_program_type__c');
		fieldsToQuery.add('Source_Detail__c');		
		fieldsToQuery.add('Territory_Routing_Country__c');
		fieldsToQuery.add('Trigger_Assignment__c');		
        fieldsToQuery.add('Trial_Type__c');				
		
		// Employee fields
		fieldsToQuery.addAll(Territory_LeadEmployeeSizeCalculator.getSoqlFields());
		
		return fieldsToQuery;
	}

	private static String getSoqlFields() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1LeadsDAO: Creating fields to query string...');
        
        List<String> fieldsList = new List<String>();
        Set<String> fieldsToQuery = getSoqlFieldSet();
        fieldsList.addAll(fieldsToQuery);
        String soqlFields = String.join(fieldsList, ', ');
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1LeadsDAO: Query fields: ' + soqlFields);        
        
        return soqlFields;
	}
	
	public static List<Lead> getLeadsWithQueriedData(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1LeadsDAO: Querying leads with relevant fields...');
		
		List<Lead> newLeads = new List<Lead>();
        String soql = getBaseSoqlQuery(leads);
        newLeads = (List<Lead>)Database.query(soql);
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1LeadsDAO: ' + newLeads.size() + ' rules queried.');
        
        return newLeads;
	}	
	
	private static String getBaseSoqlQuery(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S1LeadsDAO: Creating soql query..');
		leadIds = createLeadIdSet(leads);
		String soql = 'SELECT ' + getSoqlFields() + ' '
                    + '     FROM Lead '
                    + '     WHERE Id IN :leadIds ';           
        System.debug(System.LoggingLevel.ERROR, 'Territory_S1LeadsDAO: Base soql query: ' + soql);
        return soql;		
	}

	private static Set<String> createLeadIdSet(List<Lead> leads) {
		Set<String> leadIdSet = new Set<String>();
		for (Lead lead : leads) {
			leadIdSet.add(lead.Id);
		}
		return leadIdSet;
	}		
	
}