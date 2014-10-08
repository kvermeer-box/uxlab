public class Territory_EmployeeSegmentFieldMappingDAO {

	private static List<Territory_Employee_Segment_Field_Mapping__c> allSegmentFieldMappingsSorted;

	public static String getSoqlFields() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_EmployeeSegmentFieldMappingDAO: Getting fields to query...');
        
        // Prepare important fields to query
        List<String> fieldsToQuery = new List<String>(); 
        fieldsToQuery.add('Id');
        fieldsToQuery.add('Name');
        fieldsToQuery.add('Max_Employee_Segment__c');
        fieldsToQuery.add(getRepFieldApiName());
        fieldsToQuery.add(getTeamFieldApiName());
        
        // Format fields in dynamic soql readable fashion
        String soqlFields = String.join(fieldsToQuery, ', ');       
        System.debug(System.LoggingLevel.ERROR, 'Territory_EmployeeSegmentFieldMappingDAO: Query fields: ' + soqlFields);
        
        return soqlFields;
    }
    
    public static String getRepFieldApiName() {
    	return 'Rep_Field_API_Name__c';
    }    
    
    public static String getTeamFieldApiName() {
    	return 'Team_Field_API_Name__c';
    }
    
    public static List<String> getFieldsToQuery(String fieldApiName) {
    	List<String> fieldsToQuery = new List<String>();    	
    	List<Territory_Employee_Segment_Field_Mapping__c> mappedFields = Territory_EmployeeSegmentFieldMappingDAO.getAllMappingsSorted();
    	for (Territory_Employee_Segment_Field_Mapping__c mapping : mappedFields) { 
    		fieldsToQuery.add(String.valueOf(mapping.get(fieldApiName)));    		
    	}
        return fieldsToQuery;
    }

	public static String getBaseSoqlQuery() {
        System.debug(System.LoggingLevel.ERROR, 'Territory_EmployeeSegmentFieldMappingDAO: Getting base soql query for employee segment field mappings...');
        
        String soql = 'SELECT ' + getSoqlFields() + ' '
                    + '     FROM Territory_Employee_Segment_Field_Mapping__c ';
        System.debug(System.LoggingLevel.ERROR, 'Territory_EmployeeSegmentFieldMappingDAO: Base soql query: ' + soql);
        return soql;
    }
	
	public static List<Territory_Employee_Segment_Field_Mapping__c> getAllMappingsSorted() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_EmployeeSegmentFieldMappingDAO: Querying all employee segment field mappings with relevant fields...');
		if (allSegmentFieldMappingsSorted == null) {
			allSegmentFieldMappingsSorted = new List<Territory_Employee_Segment_Field_Mapping__c>();
			List<Territory_Employee_Segment_Field_Mapping__c> unsortedFieldMappings = new List<Territory_Employee_Segment_Field_Mapping__c>();			
	        String soql = getBaseSoqlQuery();
	        unsortedFieldMappings = (List<Territory_Employee_Segment_Field_Mapping__c>)Database.query(soql);
	        allSegmentFieldMappingsSorted = sortMappings(unsortedFieldMappings);		
	        System.debug(System.LoggingLevel.ERROR, 'Territory_EmployeeSegmentFieldMappingDAO: ' + allSegmentFieldMappingsSorted.size() + ' mappings queried.');
		}        		
        return allSegmentFieldMappingsSorted;
	}	
	
	private static List<Territory_Employee_Segment_Field_Mapping__c> sortMappings(List<Territory_Employee_Segment_Field_Mapping__c> mappings) {
		System.debug(System.LoggingLevel.ERROR, 'Territory_EmployeeSegmentFieldMappingDAO: Sorting employee segment field mappings...');
		
		// First, sort
		List<Territory_EmpSgmtFieldMappingComparable> sortableList = new List<Territory_EmpSgmtFieldMappingComparable>();
		for (Territory_Employee_Segment_Field_Mapping__c mapping : mappings) {
			Territory_EmpSgmtFieldMappingComparable comparable = new Territory_EmpSgmtFieldMappingComparable(mapping);
			sortableList.add(comparable);
		}
		sortableList.sort();
		
		// Now, return to original format
		List<Territory_Employee_Segment_Field_Mapping__c> sortedMappings = new List<Territory_Employee_Segment_Field_Mapping__c>();
		for (Territory_EmpSgmtFieldMappingComparable comp : sortableList) {
			sortedMappings.add(comp.mapping);
		}
		System.debug(System.LoggingLevel.ERROR, 'Territory_EmployeeSegmentFieldMappingDAO: Sorting employee segment field mappings: ' + sortedMappings);
		return sortedMappings;
	}

}