public class Territory_S2LeadsDAO {
	
	private static List<Territory_EntryValueField> entryValueFields;
	private static Set<String> leadIds;

	private static Set<String> getSoqlFieldSet() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadsDAO: Getting set of fields to query...'); 
		
		// Base lead fields	
		Set<String> fieldsToQuery = new Set<String>();
		fieldsToQuery.add('Id');
		fieldsToQuery.add('Name');
		fieldsToQuery.add('CreatedById');
		fieldsToQuery.add('OwnerId');
		fieldsToQuery.add('Owner.Email');
		
		// Rule finder fields
		fieldsToQuery.addAll(Territory_S2RulesFinder.getLeadFieldsForFindingRules());
		
		// Entry value fields
		fieldsToQuery.addAll(Territory_EntryValueFieldUtils.convertEntryValueFieldListToStrings(getEntryValueFieldsByPriority()));	   
		
		// Qual note fields
		fieldsToQuery.addAll(Territory_SdrQualNoteDAO.getQualNoteFieldsFromLead());
		
		// Employee fields
		fieldsToQuery.addAll(Territory_LeadAcctEmployeeSizeCalculator.getSoqlFields());
		
		// Conversion fields
		fieldsToQuery.addAll(Territory_S2LeadConverter.getLeadFieldsForConversion());	
		
		// Routed lead fields
		fieldsToQuery.addAll(Territory_RoutedLeadFactory.getStage2RoutedLeadStampedFields());
		
		// Opp member populator fields
		fieldsToQuery.addAll(Territory_OpportunityMemberPopulator.getFieldsForOppMemberPopulator());
		
		return fieldsToQuery;
	}

	private static String getSoqlFields() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadsDAO: Creating fields to query string...');
        
        List<String> fieldsList = new List<String>();
        Set<String> fieldsToQuery = getSoqlFieldSet();
        fieldsList.addAll(fieldsToQuery);
        String soqlFields = String.join(fieldsList, ', ');
        System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadsDAO: Query fields: ' + soqlFields);        
        
        return soqlFields;
	}
	
	public static List<Lead> getLeadsWithQueriedData(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadsDAO: Querying leads with relevant fields...');
		
		List<Lead> newLeads = new List<Lead>();
        String soql = getBaseSoqlQuery(leads);
        newLeads = (List<Lead>)Database.query(soql);
        System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadsDAO: ' + newLeads.size() + ' leads queried.');
        
        return newLeads;
	}	
	
	private static String getBaseSoqlQuery(List<Lead> leads) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadsDAO: Creating soql query..');
		leadIds = createLeadIdSet(leads);
		String soql = 'SELECT ' + getSoqlFields() + ' '
                    + '     FROM Lead '
                    + '     WHERE IsConverted = false ' 
                    + '			AND Id IN :leadIds ';           
        System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadsDAO: Base soql query: ' + soql);
        return soql;		
	}

	private static Set<String> createLeadIdSet(List<Lead> leads) {
		Set<String> leadIdSet = new Set<String>();
		for (Lead lead : leads) {
			leadIdSet.add(lead.Id);
		}
		return leadIdSet;
	}		
	
	public static List<Territory_EntryValueField> getEntryValueFieldsByPriority() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_S2LeadsDAO: Getting entry value fields by priority...');
		
		if (entryValueFields == null) {
			// Prepare important fields to query. String = field name. boolean = whether or not to truncate to 5 chars
	        entryValueFields = new List<Territory_EntryValueField>(); 	        	       	        
	        entryValueFields.add(new Territory_EntryValueField('Territory_Routing_Account__r.BillingCountry', null));
	        entryValueFields.add(new Territory_EntryValueField('Territory_Routing_Account__r.BillingPostalCode', 5));	        	        	        
	        
	        // Old version
	        // entryValueFields.add(new Territory_EntryValueField('Country', null));
	        // entryValueFields.add(new Territory_EntryValueField('PostalCode', 5));
		}    
        return entryValueFields;
	}

}