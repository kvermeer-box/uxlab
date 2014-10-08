public class Territory_SdrQualNoteDAO {

	public static Set<String> getQualNoteFieldsFromLead() {
		System.debug(System.LoggingLevel.ERROR, 'Territory_SdrQualNoteFactory: Getting relevant qual note lead fields..');
		
		// Prepare important fields to query
        Set<String> leadFieldsToQuery = new Set<String>(); 
        leadFieldsToQuery.add('Id');
        leadFieldsToQuery.add('OwnerId');
        leadFieldsToQuery.add('Company');
        leadFieldsToQuery.add('Number_of_Users__c');
        leadFieldsToQuery.add('Employees__c');
        leadFieldsToQuery.add('NumberOfEmployees');          
        leadFieldsToQuery.add('About_the_Company__c');
        leadFieldsToQuery.add('Business_Objective__c');
        leadFieldsToQuery.add('Pain__c');
        leadFieldsToQuery.add('Next_Steps__c');
        leadFieldsToQuery.add('Decision_Makers__c');
        leadFieldsToQuery.add('Budget__c');    
        leadFieldsToQuery.add('Purchase_Time_Frame__c');
        leadFieldsToQuery.add('Competition__c');
        leadFieldsToQuery.add('Decision_Makers__c');
        leadFieldsToQuery.add('How_They_Found_Box__c');
        leadFieldsToQuery.add('Upsell_Opportunity__c');
        leadFieldsToQuery.add('Scope_of_Deployment__c');         
        leadFieldsToQuery.add('Number_of_Upsell_Users__c');  
        leadFieldsToQuery.add('CurrencyIsoCode');    
        
		return leadFieldsToQuery;
	}
	

}